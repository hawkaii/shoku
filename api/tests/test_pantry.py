"""The pantry: the first mutable synced table.

Append-only tables never rewrite a row; the pantry must, so it is the only one
with last-write-wins and a real conflict story. These tests pin that, plus the
one thing a shared table can never get wrong: another user's rows never appear.
"""

from fastapi.testclient import TestClient


def pantry(**overrides) -> dict:
    payload = {
        "id": "p1",
        "name": "butter",
        "quantity": 500.0,
        "unit": "g",
        "aliases": ["AMUL BUTTER 500G"],
        "wanted": False,
        "source": "photo",
        "created_at": "2026-01-01T10:00:00Z",
        "updated_at": "2026-01-01T10:00:00Z",
    }
    payload.update(overrides)
    return payload


def push(client: TestClient, **tables):
    response = client.post("/v1/sync/push", json=tables)
    assert response.status_code == 200, response.text
    return response.json()


def pull(client: TestClient, **body) -> dict:
    response = client.post("/v1/sync/pull", json=body)
    assert response.status_code == 200, response.text
    return response.json()


def test_a_pantry_row_round_trips(client) -> None:
    pushed = push(client, pantry_items=[pantry()])
    assert pushed["pantry_items"][0]["result"] == "accepted"
    assert pushed["pantry_items"][0]["reason"] == "created"

    stored = pull(client)["pantry_items"][0]
    assert stored["name"] == "butter"
    assert stored["quantity"] == 500.0
    assert stored["unit"] == "g"
    assert stored["aliases"] == ["AMUL BUTTER 500G"]
    assert stored["wanted"] is False
    assert stored["source"] == "photo"
    assert stored["deleted_at"] is None


def test_a_null_quantity_is_a_real_state(client) -> None:
    push(client, pantry_items=[pantry(quantity=None, unit=None)])
    stored = pull(client)["pantry_items"][0]

    assert stored["quantity"] is None, "have it, amount unknown"
    assert stored["unit"] is None


def test_a_newer_write_wins(client) -> None:
    push(client, pantry_items=[pantry(quantity=500.0)])

    newer = push(
        client,
        pantry_items=[pantry(quantity=250.0, updated_at="2026-02-01T10:00:00Z")],
    )
    assert newer["pantry_items"][0]["result"] == "accepted"
    assert newer["pantry_items"][0]["reason"] == "newer"

    assert pull(client)["pantry_items"][0]["quantity"] == 250.0


def test_an_older_write_loses_and_does_not_change_the_row(client) -> None:
    push(client, pantry_items=[pantry(quantity=500.0, updated_at="2026-02-01T10:00:00Z")])

    stale = push(
        client,
        pantry_items=[pantry(quantity=1.0, updated_at="2026-01-01T10:00:00Z")],
    )
    assert stale["pantry_items"][0]["result"] == "conflict"
    assert stale["pantry_items"][0]["reason"] == "stale_write"
    assert pull(client)["pantry_items"][0]["quantity"] == 500.0


def test_the_same_write_twice_is_not_a_conflict(client) -> None:
    push(client, pantry_items=[pantry()])
    again = push(client, pantry_items=[pantry()])

    assert again["pantry_items"][0]["result"] == "ignored"
    assert again["pantry_items"][0]["reason"] == "already_applied"


def test_a_delete_is_a_tombstone_not_a_vanished_row(client) -> None:
    push(client, pantry_items=[pantry()])

    push(
        client,
        pantry_items=[
            pantry(updated_at="2026-03-01T10:00:00Z", deleted_at="2026-03-01T10:00:00Z")
        ],
    )

    rows = pull(client)["pantry_items"]
    assert len(rows) == 1, "the row survives so the other device hears about it"
    assert rows[0]["deleted_at"] == "2026-03-01T10:00:00Z"


def test_a_stale_resurrection_loses(client) -> None:
    push(
        client,
        pantry_items=[
            pantry(updated_at="2026-03-01T10:00:00Z", deleted_at="2026-03-01T10:00:00Z")
        ],
    )

    result = push(client, pantry_items=[pantry(updated_at="2026-01-01T10:00:00Z", deleted_at=None)])
    assert result["pantry_items"][0]["result"] == "conflict"
    assert pull(client)["pantry_items"][0]["deleted_at"] == "2026-03-01T10:00:00Z"


def test_a_future_write_is_refused(client) -> None:
    result = push(client, pantry_items=[pantry(updated_at="2099-01-01T10:00:00Z")])

    assert result["pantry_items"][0]["result"] == "conflict"
    assert result["pantry_items"][0]["reason"] == "clock_ahead"


def test_one_users_pantry_never_appears_in_anothers(app) -> None:
    with TestClient(app) as alice, TestClient(app) as bob:
        alice.headers.update({"X-Firebase-Uid": "alice"})
        bob.headers.update({"X-Firebase-Uid": "bob"})

        push(alice, pantry_items=[pantry(id="shared-id", name="butter")])
        assert pull(bob)["pantry_items"] == []

        # Bob cannot claim Alice's id, and cannot see her row.
        stolen = push(bob, pantry_items=[pantry(id="shared-id", name="ghee")])
        assert stolen["pantry_items"][0]["result"] == "conflict"
        assert stolen["pantry_items"][0]["reason"] == "id_taken"
        assert pull(bob)["pantry_items"] == []
        assert pull(alice)["pantry_items"][0]["name"] == "butter"


def test_pull_pages_pantry_rows_without_losing_any(client) -> None:
    push(client, pantry_items=[pantry(id=f"p{i}", name=f"item {i}") for i in range(4)])

    seen: list[str] = []
    cursor = None
    for _ in range(6):
        body = pull(client, limit=1, cursor=cursor)
        seen.extend(row["id"] for row in body["pantry_items"])
        if not body["has_more"]:
            break
        cursor = body["cursor"]

    assert sorted(seen) == ["p0", "p1", "p2", "p3"]

"""Sync semantics: union merge, LWW, tombstones, append-only."""

from fastapi.testclient import TestClient


def push(client: TestClient, **tables):
    response = client.post("/v1/sync/push", json=tables)
    assert response.status_code == 200, response.text
    return response.json()


def pull(client: TestClient, **body):
    response = client.post("/v1/sync/pull", json=body)
    assert response.status_code == 200, response.text
    return response.json()


def test_versions_merge_by_union_of_id(client, dish_payload, version_payload) -> None:
    push(client, dishes=[dish_payload()], versions=[version_payload(id="v1", number=1)])
    push(client, versions=[version_payload(id="v2", number=2)])

    body = pull(client)
    assert [v["id"] for v in body["versions"]] == ["v1", "v2"]
    assert [v["number"] for v in body["versions"]] == [1, 2]


def test_older_dish_write_loses(client, dish_payload) -> None:
    push(client, dishes=[dish_payload(title="Newer", updated_at="2026-03-01T00:00:00Z")])

    result = push(
        client,
        dishes=[dish_payload(title="Stale", updated_at="2026-01-01T00:00:00Z")],
    )
    assert result["dishes"][0]["result"] == "conflict"
    assert result["dishes"][0]["reason"] == "stale_write"
    assert pull(client)["dishes"][0]["title"] == "Newer"


def test_equal_timestamp_is_idempotent_not_a_conflict(client, dish_payload) -> None:
    push(client, dishes=[dish_payload(title="Same")])
    again = push(client, dishes=[dish_payload(title="Same")])

    assert again["dishes"][0]["result"] == "ignored"
    assert again["dishes"][0]["reason"] == "already_applied"


def test_newer_dish_write_wins_and_advances_server_clock(client, dish_payload) -> None:
    push(client, dishes=[dish_payload(title="Old")])
    first = pull(client)["dishes"][0]

    push(client, dishes=[dish_payload(title="New", updated_at="2026-03-01T00:00:00Z")])
    second = pull(client)["dishes"][0]

    assert second["title"] == "New"
    assert second["updated_at"] == "2026-03-01T00:00:00Z"
    # Pull pages on the server clock, which must move even though the client's
    # clock is what decided the conflict.
    assert len(pull(client)["dishes"]) == 1
    assert first["id"] == second["id"]


def test_clock_ahead_write_is_refused(client, dish_payload) -> None:
    result = push(client, dishes=[dish_payload(updated_at="2099-01-01T00:00:00Z")])
    assert result["dishes"][0]["result"] == "conflict"
    assert result["dishes"][0]["reason"] == "clock_ahead"


def test_tombstone_is_kept_and_returned(client, dish_payload) -> None:
    push(client, dishes=[dish_payload(title="Alive")])
    push(
        client,
        dishes=[
            dish_payload(
                title="Alive",
                updated_at="2026-03-01T00:00:00Z",
                deleted_at="2026-03-01T00:00:00Z",
            )
        ],
    )

    body = pull(client)
    assert len(body["dishes"]) == 1, "the row must survive as a tombstone"
    assert body["dishes"][0]["deleted_at"] is not None
    assert body["dishes"][0]["title"] == "Alive"

    # The tombstone is a normal LWW write, so a stale resurrection loses.
    result = push(
        client,
        dishes=[
            dish_payload(
                title="Resurrected",
                updated_at="2026-02-01T00:00:00Z",
                deleted_at=None,
            )
        ],
    )
    assert result["dishes"][0]["result"] == "conflict"


def test_duplicate_version_is_ignored_never_updated(
    client, dish_payload, version_payload
) -> None:
    push(client, dishes=[dish_payload()])
    push(client, versions=[version_payload(steps=["Fry"])])

    again = push(client, versions=[version_payload(steps=["Rewritten history"])])
    assert again["versions"][0]["result"] == "ignored"
    assert again["versions"][0]["reason"] == "duplicate_append_only"

    stored = pull(client)["versions"][0]
    assert stored["steps"] == ["Fry"]


def test_duplicate_cook_log_is_ignored(client, dish_payload, version_payload, cook_payload) -> None:
    push(
        client,
        dishes=[dish_payload()],
        versions=[version_payload()],
        cook_logs=[cook_payload(note="first")],
    )
    again = push(client, cook_logs=[cook_payload(note="edited")])
    assert again["cook_logs"][0]["result"] == "ignored"
    assert pull(client)["cook_logs"][0]["note"] == "first"


def test_version_for_unknown_dish_is_a_conflict(client, version_payload) -> None:
    result = push(client, versions=[version_payload(dish_id="nope")])
    assert result["versions"][0]["result"] == "conflict"
    assert result["versions"][0]["reason"] == "unknown_dish"


def test_rows_are_namespaced_per_user(app, dish_payload) -> None:
    from fastapi.testclient import TestClient

    with TestClient(app) as alice, TestClient(app) as bob:
        alice.headers.update({"X-Firebase-Uid": "alice"})
        bob.headers.update({"X-Firebase-Uid": "bob"})

        push(alice, dishes=[dish_payload(id="shared", title="Alice's")])

        assert pull(bob)["dishes"] == []

        # Bob cannot claim Alice's id, and cannot see her row.
        stolen = push(bob, dishes=[dish_payload(id="shared", title="Bob's")])
        assert stolen["dishes"][0]["result"] == "conflict"
        assert stolen["dishes"][0]["reason"] == "id_taken"
        assert pull(bob)["dishes"] == []


def test_pull_pages_with_a_cursor_without_losing_rows(client, dish_payload) -> None:
    dishes = [
        dish_payload(id=f"dish-{i}", title=f"Dish {i}", updated_at=f"2026-02-0{i+1}T00:00:00Z")
        for i in range(3)
    ]
    push(client, dishes=dishes)

    seen: list[str] = []
    cursor = None
    for _ in range(5):
        body = pull(client, limit=1, cursor=cursor)
        seen.extend(d["id"] for d in body["dishes"])
        if not body["has_more"]:
            break
        cursor = body["cursor"]

    assert sorted(seen) == ["dish-0", "dish-1", "dish-2"]
    assert len(seen) == 3, "a cursor must not duplicate or drop rows"


def test_pull_since_returns_only_later_changes(client, dish_payload) -> None:
    push(client, dishes=[dish_payload(id="a", title="A")])
    marker = pull(client)["server_time"]

    push(client, dishes=[dish_payload(id="b", title="B")])
    body = pull(client, since=marker)

    assert [d["id"] for d in body["dishes"]] == ["b"]


def test_pull_ignores_a_corrupt_cursor(client, dish_payload) -> None:
    push(client, dishes=[dish_payload()])
    body = pull(client, cursor="not-a-cursor")
    assert len(body["dishes"]) == 1


def test_push_rejects_unknown_keys(client) -> None:
    response = client.post("/v1/sync/push", json={"dishes": [], "sneaky": 1})
    assert response.status_code == 422

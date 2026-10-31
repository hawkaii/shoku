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


# ---- photos -------------------------------------------------------------


def seed_journal(client, dish_payload, version_payload, cook_payload) -> None:
    push(
        client,
        dishes=[dish_payload()],
        versions=[version_payload()],
        cook_logs=[cook_payload()],
    )


def test_photos_union_by_id_and_are_never_rewritten(
    client, dish_payload, version_payload, cook_payload, photo_payload
) -> None:
    seed_journal(client, dish_payload, version_payload, cook_payload)
    push(client, photos=[photo_payload(id="p1", key="first.jpg")])

    again = push(client, photos=[photo_payload(id="p1", key="second.jpg")])
    assert again["photos"][0]["result"] == "ignored"
    assert again["photos"][0]["reason"] == "duplicate_append_only"
    assert [p["key"] for p in pull(client)["photos"]] == ["first.jpg"]


def test_many_photos_on_one_version_are_all_kept(
    client, dish_payload, version_payload, cook_payload, photo_payload
) -> None:
    seed_journal(client, dish_payload, version_payload, cook_payload)
    photos = [photo_payload(id=f"p{i}", version_id="v1") for i in range(4)]
    result = push(client, photos=photos)

    assert [r["result"] for r in result["photos"]] == ["accepted"] * 4
    assert sorted(p["id"] for p in pull(client)["photos"]) == ["p0", "p1", "p2", "p3"]


def test_debrief_photo_hangs_off_the_cook_not_the_version(
    client, dish_payload, version_payload, cook_payload, photo_payload
) -> None:
    seed_journal(client, dish_payload, version_payload, cook_payload)
    result = push(
        client, photos=[photo_payload(id="p-debrief", role="debrief", version_id=None, cook_id="c1")]
    )

    assert result["photos"][0]["result"] == "accepted"
    stored = pull(client)["photos"][0]
    assert stored["role"] == "debrief"
    assert stored["cook_id"] == "c1"
    assert stored["version_id"] is None


def test_tombstone_is_the_only_write_a_photo_accepts(
    client, dish_payload, version_payload, cook_payload, photo_payload
) -> None:
    seed_journal(client, dish_payload, version_payload, cook_payload)
    push(client, photos=[photo_payload()])

    removed = push(
        client,
        photos=[photo_payload(deleted_at="2026-01-04T00:00:00Z", key="other.jpg")],
    )
    assert removed["photos"][0]["result"] == "accepted"
    assert removed["photos"][0]["reason"] == "tombstoned"

    stored = pull(client)["photos"][0]
    assert stored["deleted_at"] == "2026-01-04T00:00:00Z"
    assert stored["key"] == "photos/user-1/202601/abc123.jpg", "a tombstone must not rewrite the row"

    # Deletion is one-way: neither a resurrection nor a second tombstone lands.
    for resurrected in (
        photo_payload(deleted_at=None),
        photo_payload(deleted_at="2026-02-01T00:00:00Z"),
    ):
        again = push(client, photos=[resurrected])
        assert again["photos"][0]["result"] == "ignored"
        assert again["photos"][0]["reason"] == "duplicate_append_only"

    assert pull(client)["photos"][0]["deleted_at"] == "2026-01-04T00:00:00Z"


def test_photo_target_must_match_its_role(
    client, dish_payload, version_payload, cook_payload, photo_payload
) -> None:
    seed_journal(client, dish_payload, version_payload, cook_payload)

    result = push(
        client,
        photos=[
            photo_payload(id="both", version_id="v1", cook_id="c1"),
            photo_payload(id="neither", version_id=None, cook_id=None),
            photo_payload(id="debrief-on-version", role="debrief", version_id="v1", cook_id=None),
        ],
    )
    assert [r["reason"] for r in result["photos"]] == ["bad_target"] * 3


def test_photo_for_an_unknown_or_foreign_target_is_a_conflict(
    client, dish_payload, version_payload, cook_payload, photo_payload
) -> None:
    seed_journal(client, dish_payload, version_payload, cook_payload)

    result = push(
        client,
        photos=[
            photo_payload(id="ghost", version_id="nope"),
            photo_payload(id="ghost-cook", role="debrief", version_id=None, cook_id="nope"),
        ],
    )
    assert [r["reason"] for r in result["photos"]] == ["unknown_version", "unknown_cook"]


def test_a_photo_cannot_claim_someone_elses_id(client, dish_payload, version_payload, cook_payload, photo_payload, app) -> None:
    from fastapi.testclient import TestClient

    seed_journal(client, dish_payload, version_payload, cook_payload)
    push(client, photos=[photo_payload(id="p1")])

    with TestClient(app) as bob:
        bob.headers.update({"X-Firebase-Uid": "bob"})
        stolen = push(bob, photos=[photo_payload(id="p1")])
        assert stolen["photos"][0]["result"] == "conflict"
        assert stolen["photos"][0]["reason"] == "id_taken"
        assert pull(bob)["photos"] == []


def test_pull_pages_photos_without_losing_rows(
    client, dish_payload, version_payload, cook_payload, photo_payload
) -> None:
    seed_journal(client, dish_payload, version_payload, cook_payload)
    push(client, photos=[photo_payload(id=f"p{i}") for i in range(3)])

    seen: list[str] = []
    cursor = None
    for _ in range(6):
        body = pull(client, limit=1, cursor=cursor)
        seen.extend(p["id"] for p in body["photos"])
        if not body["has_more"]:
            break
        cursor = body["cursor"]

    assert sorted(seen) == ["p0", "p1", "p2"]


def test_a_short_table_is_not_replayed_on_every_page(
    client, dish_payload, version_payload, cook_payload
) -> None:
    """Tables exhaust at different lengths; the shorter one must stop.

    Regression: the cursor used to carry only the tables that still had pages,
    so a finished table restarted from the top on each call and its rows came
    back once per page.
    """
    push(
        client,
        dishes=[dish_payload()],
        versions=[version_payload()],
        cook_logs=[cook_payload(id=f"c{i}") for i in range(3)],
    )

    dishes: list[str] = []
    cooks: list[str] = []
    cursor = None
    for _ in range(10):
        body = pull(client, limit=1, cursor=cursor)
        dishes.extend(d["id"] for d in body["dishes"])
        cooks.extend(c["id"] for c in body["cook_logs"])
        if not body["has_more"]:
            break
        cursor = body["cursor"]

    assert dishes == ["dish-1"], "the exhausted dish table must not be paged again"
    assert sorted(cooks) == ["c0", "c1", "c2"]


def test_a_client_that_ignores_photos_still_terminates(
    client, dish_payload, version_payload, cook_payload, photo_payload
) -> None:
    """Photos are additive: an older client reads the fields it knows.

    The cursor is opaque, so the photos key rides back inside it even though
    this client never looks at the photos array. Paging must still finish —
    otherwise adding a table would hang every client that predates it.
    """
    seed_journal(client, dish_payload, version_payload, cook_payload)
    push(client, photos=[photo_payload(id=f"p{i}") for i in range(5)])

    dishes: list[str] = []
    cursor = None
    for _ in range(10):
        body = pull(client, limit=1, cursor=cursor)
        dishes.extend(d["id"] for d in body["dishes"])  # ignores body["photos"]
        if not body["has_more"]:
            break
        cursor = body["cursor"]
    else:
        raise AssertionError("paging never terminated for a client that ignores photos")

    assert dishes == ["dish-1"]


def test_photo_url_is_null_without_a_real_bucket(
    client, dish_payload, version_payload, cook_payload, photo_payload
) -> None:
    """The dev storage has only a placeholder base; do not promise a URL."""
    seed_journal(client, dish_payload, version_payload, cook_payload)
    push(client, photos=[photo_payload(key="photos/user-1/202601/abc.jpg")])

    photo = pull(client)["photos"][0]
    assert photo["url"] is None
    assert photo["key"] == "photos/user-1/202601/abc.jpg"


def test_photo_url_is_derived_when_the_deployment_has_a_bucket(
    app, ctx, settings, dish_payload, version_payload, cook_payload, photo_payload
) -> None:
    """A device that never uploaded this photo still needs somewhere to fetch it."""
    from fastapi.testclient import TestClient

    # The deployed shape: R2 configured, so a key has a public URL. The storage
    # adapter itself stays fake — the derivation is what is under test.
    ctx.settings = settings.model_copy(
        update={"storage_backend": "r2", "storage_public_base_url": "https://media.test/"}
    )

    with TestClient(app) as c:
        c.headers.update({"X-Firebase-Uid": "user-1"})
        seed_journal(c, dish_payload, version_payload, cook_payload)
        push(c, photos=[photo_payload(key="photos/user-1/202601/abc.jpg")])

        photo = pull(c)["photos"][0]

    assert photo["url"] == "https://media.test/photos/user-1/202601/abc.jpg"


def test_an_imported_version_carries_its_handles(client, dish_payload, version_payload) -> None:
    """The client sends ``origin_handle``/``origin_platform`` on every import.

    ``VersionRowIn`` forbids extra fields, so a payload with them used to be
    rejected with a 422 — and the client treats a rejected push as "nothing
    saved", leaving every dish after the first one stuck on the device forever.
    """
    push(
        client,
        dishes=[dish_payload()],
        versions=[
            version_payload(
                origin_kind="import",
                origin_creator="Ralston D'Souza",
                origin_handle="@kanji_club_",
                origin_platform="instagram",
                origin_url="https://www.instagram.com/reel/DctNWIDT540/",
                origin_shortcode="DctNWIDT540",
            )
        ],
    )

    version = pull(client)["versions"][0]
    assert version["origin_handle"] == "@kanji_club_"
    assert version["origin_platform"] == "instagram"


def test_a_version_without_handles_still_pushes(client, dish_payload, version_payload) -> None:
    """Provenance is optional: an older client sends neither field."""
    push(client, dishes=[dish_payload()], versions=[version_payload()])

    version = pull(client)["versions"][0]
    assert version["origin_handle"] is None
    assert version["origin_platform"] is None

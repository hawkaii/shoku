"""The Wall: only what was published, and nothing about who published it.

Two properties matter more than any single case here:

* an extraction appears only because someone pressed publish, so nothing
  arrives by accident;
* a card can carry no trace of a user's own work — no dish, no version, no
  cook, no photo, and no importer.
"""

from datetime import datetime, timezone

import pytest
from fastapi.testclient import TestClient

from shoku_api.models import ContentCache

RECIPE = {
    "title": "Paneer butter masala",
    "servings": 3,
    "minutes": 35,
    "kcal": 0,
    "protein": 0,
    "ingredients": [{"name": "paneer", "amount": "250 g", "grams": 250}],
    "steps": ["Fry the paneer.", "Simmer the gravy."],
    "tags": ["weeknight"],
}


def add_row(
    session,
    shortcode: str,
    *,
    title: str | None = None,
    shared: bool = False,
    created_at: str = "2026-10-01T10:00:00Z",
    with_parse: bool = True,
    deleted: bool = False,
    thumbnail_url: str | None = None,
) -> ContentCache:
    """Seed a cache row directly. Product code never sets ``shared`` here."""
    recipe = dict(RECIPE, **({"title": title} if title else {})) if with_parse else None
    row = ContentCache(
        shortcode=shortcode,
        structured_json=recipe,
        prose_json={"summary": ""},
        creator="Ravi",
        creator_handle="@ravi",
        platform="instagram",
        thumbnail_url=thumbnail_url,
        source_url=f"https://www.instagram.com/reel/{shortcode}/",
        extraction_version=3,
        shared=shared,
        created_at=datetime.fromisoformat(created_at.replace("Z", "+00:00")),
        deleted_at=datetime.now(timezone.utc) if deleted else None,
    )
    session.add(row)
    session.commit()
    return row


def feed(client: TestClient, **params) -> dict:
    response = client.get("/v1/feed", params=params)
    assert response.status_code == 200, response.text
    return response.json()


def test_an_unshared_row_never_appears(client, session) -> None:
    add_row(session, "quiet1", title="Never published")
    add_row(session, "loud1", title="Published")
    assert client.put("/v1/content/loud1/share").json()["shared"] is True

    titles = [item["title"] for item in feed(client)["items"]]

    assert titles == ["Published"]


def test_publishing_is_an_explicit_act_not_a_side_effect_of_import(client, session) -> None:
    """A row that merely exists must stay invisible until someone publishes it."""
    add_row(session, "imported1")
    assert feed(client)["items"] == []


def test_unpublishing_takes_it_off_the_wall(client, session) -> None:
    add_row(session, "loud1")
    client.put("/v1/content/loud1/share")
    assert len(feed(client)["items"]) == 1

    assert client.delete("/v1/content/loud1/share").json()["shared"] is False
    assert feed(client)["items"] == []


def test_a_taken_down_row_disappears(client, session) -> None:
    add_row(session, "loud1")
    client.put("/v1/content/loud1/share")
    assert len(feed(client)["items"]) == 1

    assert client.delete("/v1/content/loud1").status_code == 204
    assert feed(client)["items"] == [], "a takedown must outrank publish"


def test_a_shared_row_with_no_parse_never_appears(client, session) -> None:
    add_row(session, "empty1", with_parse=False, shared=True)
    assert feed(client)["items"] == []


def test_a_tombstoned_row_never_appears_even_if_the_parse_is_present(client, session) -> None:
    """Belt and braces: ``deleted_at`` alone must be enough to hide a row."""
    add_row(session, "gone1", shared=True, deleted=True)
    assert feed(client)["items"] == []


def test_publishing_a_row_that_cannot_be_shown_is_404(client, session) -> None:
    assert client.put("/v1/content/nope/share").status_code == 404

    add_row(session, "gone2", deleted=True)
    assert client.put("/v1/content/gone2/share").status_code == 404

    add_row(session, "empty2", with_parse=False)
    assert client.put("/v1/content/empty2/share").status_code == 404


def test_the_feed_and_the_publish_switch_require_a_identity(anonymous: TestClient) -> None:
    assert anonymous.get("/v1/feed").status_code == 401
    assert anonymous.put("/v1/content/x/share").status_code == 401
    assert anonymous.post("/v1/content/x/report").status_code == 401


def test_a_card_carries_the_extraction_and_no_importer(client, session) -> None:
    add_row(session, "loud1", thumbnail_url="https://media.test/cover.jpg")
    client.put("/v1/content/loud1/share")

    item = feed(client)["items"][0]

    assert set(item) == {
        "shortcode",
        "title",
        "thumbnail_url",
        "creator",
        "creator_handle",
        "platform",
        "steps",
        "tags",
        "extraction_version",
        "created_at",
        "url",
    }
    assert "user_id" not in item and "importer" not in item
    assert item["creator"] == "Ravi"
    assert item["creator_handle"] == "@ravi"
    assert item["platform"] == "instagram"
    assert item["url"] == "https://www.instagram.com/reel/loud1/"
    assert item["steps"] == ["Fry the paneer.", "Simmer the gravy."]
    assert item["tags"] == ["weeknight"]


def test_a_users_own_work_cannot_reach_a_card(client, session, ctx) -> None:
    """The feed never joins a user-owned table, so an edit cannot leak.

    A dish with the same title-ish content, a version that rewrote the steps, a
    cook and a photo all exist for this user; the card must still be the
    extraction, because that is the only table it reads.
    """
    add_row(session, "loud1", title="Extracted title")
    client.put("/v1/content/loud1/share")

    client.post(
        "/v1/sync/push",
        json={
            "dishes": [
                {
                    "id": "dish-1",
                    "title": "My private rename",
                    "steps": ["My private edit"],
                    "created_at": "2026-01-01T10:00:00Z",
                    "updated_at": "2026-01-01T10:00:00Z",
                }
            ],
            "versions": [
                {
                    "id": "v1",
                    "dish_id": "dish-1",
                    "steps": ["Secret method"],
                    "created_at": "2026-01-01T10:00:00Z",
                }
            ],
            "cook_logs": [
                {
                    "id": "c1",
                    "dish_id": "dish-1",
                    "cooked_at": "2026-01-02T19:00:00Z",
                    "note": "private note",
                }
            ],
            "photos": [
                {
                    "id": "p1",
                    "role": "version",
                    "version_id": "v1",
                    "key": "photos/user-1/202601/x.jpg",
                    "created_at": "2026-01-03T10:00:00Z",
                }
            ],
        },
    )

    item = feed(client)["items"][0]

    assert item["title"] == "Extracted title"
    assert item["steps"] == ["Fry the paneer.", "Simmer the gravy."]
    assert "Secret method" not in str(item)
    assert "private note" not in str(item)


def test_newest_first_and_paging_does_not_repeat(client, session) -> None:
    add_row(session, "old1", title="Oldest", created_at="2026-10-01T10:00:00Z", shared=True)
    add_row(session, "mid1", title="Middle", created_at="2026-10-02T10:00:00Z", shared=True)
    add_row(session, "new1", title="Newest", created_at="2026-10-03T10:00:00Z", shared=True)

    seen: list[str] = []
    cursor = None
    for _ in range(5):
        body = feed(client, limit=2, **({"cursor": cursor} if cursor else {}))
        seen.extend(item["title"] for item in body["items"])
        if not body["has_more"]:
            break
        cursor = body["cursor"]

    assert seen == ["Newest", "Middle", "Oldest"]


def test_rows_sharing_a_timestamp_still_page(client, session) -> None:
    """Bursts of imports share a created_at; the shortcode breaks the tie."""
    for shortcode in ("aaa1", "bbb1", "ccc1"):
        add_row(session, shortcode, title=shortcode, shared=True)

    seen: list[str] = []
    cursor = None
    for _ in range(5):
        body = feed(client, limit=1, **({"cursor": cursor} if cursor else {}))
        seen.extend(item["shortcode"] for item in body["items"])
        if not body["has_more"]:
            break
        cursor = body["cursor"]

    assert seen == ["ccc1", "bbb1", "aaa1"]


def test_a_corrupt_cursor_starts_the_page_over(client, session) -> None:
    add_row(session, "loud1")
    client.put("/v1/content/loud1/share")

    assert len(feed(client, cursor="not-a-cursor")["items"]) == 1


# ---- reports --------------------------------------------------------------


def test_a_duplicate_report_does_not_increment(client, session) -> None:
    add_row(session, "loud1", shared=True)

    first = client.post("/v1/content/loud1/report").json()
    second = client.post("/v1/content/loud1/report").json()

    assert first["reported_count"] == 1
    assert second["reported_count"] == 1, "one account, however many taps, is one report"


def test_distinct_users_reach_the_threshold_and_unshare(client, session, ctx, app) -> None:
    """Two people agreeing is already a moderation signal, not one."""
    ctx.settings = ctx.settings.model_copy(update={"feed_report_threshold": 2})
    add_row(session, "loud1", shared=True)

    assert client.post("/v1/content/loud1/report").json()["shared"] is True

    with TestClient(app) as second:
        second.headers.update({"X-Firebase-Uid": "user-2"})
        result = second.post("/v1/content/loud1/report").json()

    assert result["reported_count"] == 2
    assert result["shared"] is False, "the threshold must unshare it"
    assert feed(client)["items"] == []


def test_below_the_threshold_it_stays_up(client, session) -> None:
    add_row(session, "loud1", shared=True)
    assert client.post("/v1/content/loud1/report").json()["shared"] is True
    assert len(feed(client)["items"]) == 1


def test_reporting_does_not_delete_the_extraction(client, session, ctx) -> None:
    """Unshared, not taken down: everyone's own import still works."""
    ctx.settings = ctx.settings.model_copy(update={"feed_report_threshold": 2})
    add_row(session, "loud1", shared=True)
    client.post("/v1/content/loud1/report")
    with TestClient(client.app) as second:
        second.headers.update({"X-Firebase-Uid": "user-2"})
        second.post("/v1/content/loud1/report")

    assert client.get("/v1/content/loud1").status_code == 200
    assert feed(client)["items"] == []


def test_reporting_an_unknown_row_is_404(client) -> None:
    assert client.post("/v1/content/nope/report").status_code == 404


@pytest.mark.parametrize("threshold", [0, 1, -1])
def test_a_threshold_below_two_is_refused(client, session, ctx, threshold) -> None:
    """A threshold of one is an unshare button for any single account."""
    ctx.settings = ctx.settings.model_copy(update={"feed_report_threshold": threshold})
    add_row(session, "loud1", shared=True)

    response = client.post("/v1/content/loud1/report")

    assert response.status_code == 503
    assert client.get("/v1/feed").status_code == 200

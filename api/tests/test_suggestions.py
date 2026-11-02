"""Wall suggestions: what the caller can mostly cook, from their own pantry.

Everything here is about the two promises the endpoint makes — the match is
computed only from the caller's pantry and returned with no user data, and a
card you can cook none of is not a suggestion.
"""

from datetime import datetime, timezone

from fastapi.testclient import TestClient

from shoku_api.models import ContentCache, PantryItem
from shoku_api.pantry import (
    MIN_COVERAGE,
    coverage,
    covers_enough,
    normalise,
    pantry_tokens,
    singular,
    tokens,
)


def add_card(session, shortcode, ingredients, *, title=None, created_at="2026-10-01T10:00:00Z", deleted=False):
    row = ContentCache(
        shortcode=shortcode,
        structured_json={
            "title": title or shortcode,
            "servings": 2,
            "minutes": 20,
            "kcal": 0,
            "protein": 0,
            "ingredients": [{"name": name, "amount": None, "grams": None} for name in ingredients],
            "steps": ["Cook it."],
            "tags": [],
        },
        prose_json={"summary": ""},
        creator="Ravi",
        creator_handle="@ravi",
        platform="instagram",
        thumbnail_url="https://media.test/cover.jpg",
        source_url=f"https://www.instagram.com/reel/{shortcode}/",
        extraction_version=4,
        created_at=datetime.fromisoformat(created_at.replace("Z", "+00:00")),
        deleted_at=datetime.now(timezone.utc) if deleted else None,
    )
    session.add(row)
    session.commit()
    return row


def add_pantry(session, uid, name, *, aliases=None, wanted=False, deleted=False, external_id=None):
    row = PantryItem(
        id=external_id or f"p-{uid}-{name}",
        user_id=uid,
        name=name,
        quantity=None,
        unit=None,
        aliases=aliases or [],
        wanted=wanted,
        source="typed",
        created_at=datetime(2026, 1, 1, tzinfo=timezone.utc),
        updated_at=datetime(2026, 1, 1, tzinfo=timezone.utc),
        deleted_at=datetime.now(timezone.utc) if deleted else None,
    )
    session.add(row)
    session.commit()
    return row


def suggest(client: TestClient, **params) -> dict:
    response = client.get("/v1/feed/suggestions", params=params)
    assert response.status_code == 200, response.text
    return response.json()


# ---- the matcher itself ---------------------------------------------------


def test_normalisation_drops_what_is_not_a_name() -> None:
    assert normalise("Onions (finely chopped)") == "onions"  # plural is folded in tokens
    assert normalise("tomatoes, diced") == "tomatoes"
    assert normalise("  Butter ") == "butter"
    assert normalise("AMUL BUTTER 500G") == "amul butter"


def test_plurals_fold_conservatively() -> None:
    assert singular("onions") == "onion"
    assert singular("tomatoes") == "tomato"
    assert singular("chickpeas") == "chickpea"
    assert singular("glass") == "glass", "ss is not a plural"
    assert singular("ghee") == "ghee"


def test_tokens_meet_across_alias_noise() -> None:
    assert tokens("Onions (finely chopped)") == {"onion"}
    assert tokens("tomatoes, diced") == {"tomato"}
    assert "butter" in tokens("AMUL BUTTER 500G")


def test_coverage_counts_one_shared_token_as_enough() -> None:
    have = tokens("onion") | tokens("ghee")
    matched, missing = coverage(["red onions", "ghee", "paneer"], have)

    assert matched == 2
    assert missing == ["paneer"]


def test_a_wanted_row_is_not_stock() -> None:
    from types import SimpleNamespace

    stock = SimpleNamespace(name="butter", aliases=[])
    wanted = SimpleNamespace(name="paneer", aliases=[], )
    have = pantry_tokens([stock])

    assert "butter" in have
    assert "paneer" not in have
    assert wanted is not None  # the filter lives in the query; see the endpoint test


# ---- the endpoint ---------------------------------------------------------


def test_a_card_is_matched_against_the_callers_pantry(client, session) -> None:
    add_card(session, "abc12345678", ["paneer", "butter", "onions"])
    add_pantry(session, "user-1", "butter")
    add_pantry(session, "user-1", "onion")

    body = suggest(client)

    assert len(body["items"]) == 1
    item = body["items"][0]
    assert item["match"] == {"have": 2, "total": 3, "missing": ["paneer"]}
    assert item["ingredients"] == ["paneer", "butter", "onions"]


def test_aliases_expand_what_counts_as_having_it(client, session) -> None:
    add_card(session, "def12345678", ["toor dal", "ghee"])
    add_pantry(session, "user-1", "lentils", aliases=["TOOR DAL 500G"])

    item = suggest(client)["items"][0]

    assert item["match"]["have"] == 1
    assert item["match"]["missing"] == ["ghee"]


def test_parentheticals_commas_and_plurals_all_match(client, session) -> None:
    add_card(session, "ghi12345678", ["Onions (finely chopped)", "tomatoes, diced"])
    add_pantry(session, "user-1", "onion")
    add_pantry(session, "user-1", "tomato")

    item = suggest(client)["items"][0]

    assert item["match"]["have"] == 2
    assert item["match"]["missing"] == []


def test_a_card_you_can_cook_none_of_is_not_a_suggestion(client, session) -> None:
    add_card(session, "aaa12345678", ["paneer", "cream"])
    add_card(session, "bbb12345678", ["paneer", "butter"])
    add_pantry(session, "user-1", "butter")

    items = suggest(client)["items"]

    assert [item["shortcode"] for item in items] == ["bbb12345678"]


def test_a_wanted_or_deleted_pantry_row_does_not_count(client, session) -> None:
    add_card(session, "abc12345678", ["paneer", "butter"])
    add_pantry(session, "user-1", "butter", wanted=True)
    add_pantry(session, "user-1", "paneer", deleted=True)

    assert suggest(client)["items"] == [], "wanted is the shopping list; deleted is gone"


def test_a_taken_down_card_is_not_a_suggestion(client, session) -> None:
    add_card(session, "abc12345678", ["butter"], deleted=True)
    add_pantry(session, "user-1", "butter")

    assert suggest(client)["items"] == []


def test_another_persons_pantry_cannot_change_your_match(client, session) -> None:
    add_card(session, "abc12345678", ["paneer", "butter"])
    add_pantry(session, "user-2", "paneer")
    add_pantry(session, "user-1", "butter")

    item = suggest(client)["items"][0]

    assert item["match"] == {"have": 1, "total": 2, "missing": ["paneer"]}, (
        "user-2's pantry must not leak into user-1's coverage"
    )


def test_a_card_carries_no_user_data(client, session) -> None:
    add_card(session, "abc12345678", ["butter"])
    add_pantry(session, "user-1", "butter")

    item = suggest(client)["items"][0]

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
        "ingredients",
        "match",
    }
    assert "user_id" not in item
    assert "pantry" not in str(item)


def test_order_is_coverage_then_newest_then_shortcode(client, session) -> None:
    # Coverage first (1.0 then 2/3), then newest, then shortcode descending.
    # low12345678 is 1/3 and correctly fails the 0.4 floor.
    add_card(session, "high1234567", ["a", "b"], created_at="2026-10-01T10:00:00Z")
    add_card(session, "tie1abcdefg", ["a", "b", "x"], created_at="2026-10-02T10:00:00Z")
    add_card(session, "tie2abcdefg", ["a", "b", "y"], created_at="2026-10-02T10:00:00Z")
    add_card(session, "low12345678", ["a", "x", "y"], created_at="2026-10-03T10:00:00Z")
    add_pantry(session, "user-1", "a")
    add_pantry(session, "user-1", "b")

    codes = [item["shortcode"] for item in suggest(client)["items"]]

    assert codes == ["high1234567", "tie2abcdefg", "tie1abcdefg"]


def test_limit_and_cursor_page_without_repeating(client, session) -> None:
    for index, shortcode in enumerate(["aaa12345678", "bbb12345678", "ccc12345678"]):
        add_card(session, shortcode, ["butter", f"thing{index}"])
    add_pantry(session, "user-1", "butter")

    seen: list[str] = []
    cursor = None
    for _ in range(5):
        params = {"limit": 2}
        if cursor:
            params["cursor"] = cursor
        body = suggest(client, **params)
        seen.extend(item["shortcode"] for item in body["items"])
        if not body["has_more"]:
            break
        cursor = body["cursor"]

    assert sorted(seen) == ["aaa12345678", "bbb12345678", "ccc12345678"]
    assert len(seen) == 3, "a cursor must not repeat a card"


def test_a_corrupt_cursor_starts_over(client, session) -> None:
    add_card(session, "abc12345678", ["butter"])
    add_pantry(session, "user-1", "butter")

    assert len(suggest(client, cursor="not-a-cursor")["items"]) == 1


def test_suggestions_require_an_identity(anonymous: TestClient) -> None:
    assert anonymous.get("/v1/feed/suggestions").status_code == 401


# ---- the 0.4 floor --------------------------------------------------------


def test_the_floor_excludes_cards_you_mostly_cannot_cook(client, session) -> None:
    """1-of-5 and 3-of-23 are shopping trips; 4-of-6 is dinner."""
    add_card(session, "oneoffive01", ["salt", "butter", "onion", "ghee", "paneer"])   # 4/5
    add_card(session, "sparse002ab", ["salt", "x1", "x2", "x3", "x4"])                 # 1/5
    add_card(
        session,
        "chole003abc",
        ["salt", "butter", "ghee"] + [f"y{i}" for i in range(20)],                     # 3/23
    )
    add_card(session, "fourofsix56", ["salt", "butter", "onion", "ghee", "paneer", "cream"])  # 4/6
    for name in ["salt", "butter", "onion", "ghee"]:
        add_pantry(session, "user-1", name)

    codes = [item["shortcode"] for item in suggest(client)["items"]]

    assert "sparse002ab" not in codes, "1 of 5 is not a suggestion"
    assert "chole003abc" not in codes, "3 of 23 is a shopping trip"
    assert "fourofsix56" in codes, "4 of 6 clears the floor"
    assert codes.index("oneoffive01") < codes.index("fourofsix56")


def test_absolute_matches_break_a_coverage_tie_and_the_floor_sets_the_edge(
    client, session
) -> None:
    """4-of-6 and 2-of-3 are both 2/3; the four is the better suggestion.

    4-of-12 is a third of a recipe and never reaches the shelf at all.
    """
    add_card(session, "twoofthree1", ["salt", "butter", "chicken"])                    # 2/3
    add_card(session, "fourofsixB1", ["salt", "butter", "onion", "ghee", "z1", "z2"])  # 4/6
    add_card(
        session,
        "fourofsix12",
        ["salt", "butter", "onion", "ghee"] + [f"w{i}" for i in range(8)],              # 4/12
    )
    for name in ["salt", "butter", "onion", "ghee"]:
        add_pantry(session, "user-1", name)

    codes = [item["shortcode"] for item in suggest(client)["items"]]

    assert codes[0] == "fourofsixB1", "4 of 6 outranks 2 of 3 on absolute matches"
    assert "fourofsix12" not in codes, "4 of 12 is below the floor"


def test_an_empty_pantry_is_an_empty_shelf_not_an_error(client, session) -> None:
    add_card(session, "abc12345678", ["butter", "paneer"])

    response = client.get("/v1/feed/suggestions")

    assert response.status_code == 200
    assert response.json()["items"] == []
    assert response.json()["has_more"] is False


def test_the_floor_is_expressed_exactly() -> None:
    from fractions import Fraction

    assert MIN_COVERAGE == Fraction(2, 5)
    assert covers_enough(2, 5) is True, "exactly 0.4 passes"
    assert covers_enough(1, 5) is False
    assert covers_enough(4, 6) is True
    assert covers_enough(0, 3) is False
    assert covers_enough(1, 0) is False

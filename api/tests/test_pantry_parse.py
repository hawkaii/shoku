"""Receipt parsing: one batched call, and nothing invented.

The endpoint exists for lines the device could not read, so the tests are mostly
about what must *not* come back: a line nobody sent, a quantity nobody stated, a
unit nobody uses.
"""

import itertools
from datetime import datetime, timezone

from fastapi.testclient import TestClient

from shoku_api.domain.errors import Unavailable
from shoku_api.pantry_parse import FakePantryParser

_requests = itertools.count(1)


def parse(client: TestClient, lines=None, **overrides):
    payload = {
        "request_id": f"req-{next(_requests):08d}",
        "lines": lines if lines is not None else ["AMUL BUTTER 500G"],
    }
    payload.update(overrides)
    return client.post("/v1/pantry/parse", json=payload)


def arm(ctx, items) -> FakePantryParser:
    parser = FakePantryParser(items=items)
    ctx.pantry_parser = parser
    return parser


# ---- the happy path -------------------------------------------------------


def test_a_branded_line_comes_back_as_food(client, ctx) -> None:
    arm(ctx, [{"line": "AMUL BUTTER 500G", "name": "butter", "quantity": 500, "unit": "g"}])

    body = parse(client).json()

    assert body["items"] == [
        {"line": "AMUL BUTTER 500G", "name": "butter", "quantity": 500.0, "unit": "g"}
    ]
    assert body["remaining"] == 2
    assert datetime.fromisoformat(body["reset_at"].replace("Z", "+00:00")).tzinfo is not None


def test_one_call_per_receipt_not_one_per_line(client, ctx) -> None:
    parser = arm(
        ctx,
        [
            {"line": "AMUL BUTTER 500G", "name": "butter", "quantity": 500, "unit": "g"},
            {"line": "2 X LAYS CLASSIC", "name": "potato chips", "quantity": 2, "unit": "pcs"},
        ],
    )

    body = parse(client, lines=["AMUL BUTTER 500G", "2 X LAYS CLASSIC", "TATA SALT 1KG"]).json()

    assert parser.calls == 1, "a receipt is one request"
    assert parser.last_lines == ("AMUL BUTTER 500G", "2 X LAYS CLASSIC", "TATA SALT 1KG")
    assert len(body["items"]) == 2


def test_items_follow_the_order_of_the_lines_sent(client, ctx) -> None:
    arm(
        ctx,
        [
            {"line": "TATA SALT 1KG", "name": "salt", "quantity": 1, "unit": "kg"},
            {"line": "AMUL BUTTER 500G", "name": "butter", "quantity": 500, "unit": "g"},
        ],
    )

    items = parse(client, lines=["AMUL BUTTER 500G", "TATA SALT 1KG"]).json()["items"]

    assert [item["line"] for item in items] == ["AMUL BUTTER 500G", "TATA SALT 1KG"]


# ---- what must not come back ---------------------------------------------


def test_a_line_that_names_no_food_is_omitted(client, ctx) -> None:
    arm(
        ctx,
        [
            {"line": "AMUL BUTTER 500G", "name": "butter", "quantity": 500, "unit": "g"},
            # No entry for the garbage line: the model omitted it, as instructed.
        ],
    )

    body = parse(client, lines=["AMUL BUTTER 500G", "asdfgh"]).json()

    assert [item["name"] for item in body["items"]] == ["butter"]


def test_a_line_the_client_never_sent_is_dropped(client, ctx) -> None:
    """A hallucinated line has no row on the review sheet, so it cannot be confirmed."""
    arm(
        ctx,
        [
            {"line": "AMUL BUTTER 500G", "name": "butter", "quantity": 500, "unit": "g"},
            {"line": "DETTOL 1L", "name": "handwash", "quantity": 1, "unit": "l"},
        ],
    )

    body = parse(client, lines=["AMUL BUTTER 500G"]).json()

    assert [item["line"] for item in body["items"]] == ["AMUL BUTTER 500G"]


def test_a_rewritten_line_is_dropped_rather_than_echoed_wrong(client, ctx) -> None:
    arm(ctx, [{"line": "AMUL BUTTER", "name": "butter", "quantity": 500, "unit": "g"}])

    body = parse(client, lines=["AMUL BUTTER 500G"]).json()

    assert body["items"] == []


def test_the_line_is_invalid_and_rejected(client) -> None:
    assert parse(client, lines=[]).status_code == 422
    assert parse(client, lines=["x"] * 21).status_code == 422
    assert parse(client, lines=["x" * 301]).status_code == 422
    assert parse(client, lines=["   "]).status_code == 422


# ---- the two invented fields ---------------------------------------------


def test_a_quantity_nobody_stated_is_refused(client, ctx) -> None:
    """The line holds no number, so any quantity is an invention."""
    arm(ctx, [{"line": "LAYS CLASSIC", "name": "potato chips", "quantity": 6, "unit": "pcs"}])

    item = parse(client, lines=["LAYS CLASSIC"]).json()["items"][0]

    assert item["quantity"] is None, "a missing amount is the correct answer"
    assert item["unit"] is None, "and a unit with no amount is noise"


def test_a_stated_quantity_is_kept(client, ctx) -> None:
    arm(ctx, [{"line": "2 X LAYS CLASSIC", "name": "potato chips", "quantity": 2, "unit": "pcs"}])

    item = parse(client, lines=["2 X LAYS CLASSIC"]).json()["items"][0]

    assert item["quantity"] == 2.0
    assert item["unit"] == "pcs"


def test_an_unknown_unit_is_rejected_not_coerced(client, ctx) -> None:
    arm(ctx, [{"line": "AMUL BUTTER 500G", "name": "butter", "quantity": 500, "unit": "cups"}])

    item = parse(client).json()["items"][0]

    assert item["unit"] is None, "an unknown unit is worse than no unit"
    assert item["quantity"] == 500.0, "the amount survives; only the unit is refused"


def test_an_absurd_quantity_is_refused(client, ctx) -> None:
    arm(ctx, [{"line": "AMUL BUTTER 500G", "name": "butter", "quantity": -1, "unit": "g"}])

    assert parse(client).json()["items"][0]["quantity"] is None


def test_one_item_per_line_even_if_the_model_sends_two(client, ctx) -> None:
    arm(
        ctx,
        [
            {"line": "AMUL BUTTER 500G", "name": "butter", "quantity": 500, "unit": "g"},
            {"line": "AMUL BUTTER 500G", "name": "butter again", "quantity": 500, "unit": "g"},
        ],
    )

    assert len(parse(client).json()["items"]) == 1


# ---- metering -------------------------------------------------------------


def test_the_cap_is_enforced_with_a_reset_time(client, ctx) -> None:
    arm(ctx, [{"line": "AMUL BUTTER 500G", "name": "butter", "quantity": 500, "unit": "g"}])

    codes = [parse(client).status_code for _ in range(4)]  # cap is 3 in test settings
    assert codes == [200, 200, 200, 429]

    body = parse(client).json()
    assert body["error"] == "daily_cap_reached"
    assert body["reset_at"]


def test_a_retried_request_id_is_metered_once(client, ctx) -> None:
    arm(ctx, [{"line": "AMUL BUTTER 500G", "name": "butter", "quantity": 500, "unit": "g"}])

    first = parse(client, request_id="retry-parse-01").json()
    second = parse(client, request_id="retry-parse-01").json()

    assert first["remaining"] == second["remaining"] == 2


def test_a_failed_call_releases_the_reservation(client, ctx) -> None:
    class BrokenParser:
        name = "broken"

        def parse(self, lines):
            raise Unavailable(detail="upstream is down")

    ctx.pantry_parser = BrokenParser()
    assert parse(client).status_code == 503

    arm(ctx, [{"line": "AMUL BUTTER 500G", "name": "butter", "quantity": 500, "unit": "g"}])
    assert parse(client).json()["remaining"] == 2, "a failed call is not charged"


def test_a_failed_call_can_be_retried_with_the_same_request_id(client, ctx) -> None:
    class BrokenParser:
        name = "broken"

        def parse(self, lines):
            raise Unavailable(detail="upstream is down")

    ctx.pantry_parser = BrokenParser()
    assert parse(client, request_id="retry-after-fail").status_code == 503

    arm(ctx, [{"line": "AMUL BUTTER 500G", "name": "butter", "quantity": 500, "unit": "g"}])
    assert parse(client, request_id="retry-after-fail").json()["remaining"] == 2


def test_the_parse_cap_is_separate_from_the_assistant_cap(client, ctx, dish_payload, version_payload) -> None:
    """A shopping bag must not spend the allowance for asking about a recipe."""
    client.post(
        "/v1/sync/push",
        json={"dishes": [dish_payload()], "versions": [version_payload()]},
    )
    ctx.assistant_model = __import__("shoku_api.assistant", fromlist=["FakeAssistantModel"]).FakeAssistantModel()
    assert (
        client.post(
            "/v1/assistant/ask",
            json={"dish_id": "dish-1", "question": "salt?", "request_id": "talk-0001"},
        ).json()["remaining"]
        == 2
    )

    arm(ctx, [{"line": "AMUL BUTTER 500G", "name": "butter", "quantity": 500, "unit": "g"}])
    assert parse(client).json()["remaining"] == 2, "an ask did not spend a parse"


def test_parsing_requires_an_identity(anonymous: TestClient) -> None:
    response = anonymous.post(
        "/v1/pantry/parse", json={"request_id": "anon-0001", "lines": ["AMUL BUTTER 500G"]}
    )
    assert response.status_code == 401

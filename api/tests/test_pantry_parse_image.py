"""Reading a receipt photograph: one vision call, the same rules as text.

The tests are mostly about what must not come back, plus the two ways a body is
refused before it costs a model call: too many bytes, or bytes that are not the
format the client declared.
"""

import base64
import itertools

import pytest
from fastapi.testclient import TestClient

from shoku_api.domain.errors import Unavailable
from shoku_api.pantry_parse import FakePantryImageParser

_requests = itertools.count(1)

PNG = b"\x89PNG\r\n\x1a\n" + b"0" * 64
JPEG = b"\xff\xd8\xff\xe0" + b"0" * 64


def b64(data: bytes) -> str:
    return base64.b64encode(data).decode()


def parse_image(client: TestClient, image: bytes = PNG, **overrides):
    payload = {
        "request_id": f"img-{next(_requests):08d}",
        "mime_type": "image/png",
        "image_base64": b64(image),
    }
    payload.update(overrides)
    return client.post("/v1/pantry/parse-image", json=payload)


def arm(ctx, items) -> FakePantryImageParser:
    parser = FakePantryImageParser(items=items)
    ctx.pantry_image_parser = parser
    return parser


BUTTER = {"line": "AMUL BUTTER 500G", "name": "butter", "quantity": 500, "unit": "g"}


# ---- the reading ----------------------------------------------------------


def test_a_receipt_line_comes_back_as_food(client, ctx) -> None:
    arm(ctx, [BUTTER])

    body = parse_image(client).json()

    assert body["items"] == [
        {"line": "AMUL BUTTER 500G", "name": "butter", "quantity": 500.0, "unit": "g"}
    ]
    assert body["remaining"] == 2
    assert body["reset_at"]


def test_the_model_receives_the_image_and_the_mime(client, ctx) -> None:
    parser = arm(ctx, [BUTTER])

    parse_image(client, image=JPEG, mime_type="image/jpeg")

    assert parser.calls == 1, "one receipt is one call"
    assert parser.last_mime == "image/jpeg"
    assert parser.last_image == b64(JPEG)


def test_an_unreadable_image_is_an_empty_list_not_an_error(client, ctx) -> None:
    arm(ctx, [])

    response = parse_image(client)

    assert response.status_code == 200
    assert response.json()["items"] == []


def test_a_non_food_row_is_dropped(client, ctx) -> None:
    arm(ctx, [BUTTER, {"line": "TOTAL 1450.00", "name": "", "quantity": None, "unit": None}])

    items = parse_image(client).json()["items"]

    assert [item["name"] for item in items] == ["butter"]


# ---- the two invented fields ---------------------------------------------


def test_an_unknown_unit_is_rejected_not_coerced(client, ctx) -> None:
    arm(ctx, [{"line": "AMUL BUTTER 500G", "name": "butter", "quantity": 500, "unit": "cups"}])

    item = parse_image(client).json()["items"][0]

    assert item["unit"] is None
    assert item["quantity"] == 500.0, "the amount survives; only the unit is refused"


def test_an_amount_the_row_never_stated_is_refused(client, ctx) -> None:
    """The model's own transcription of the row has no digit, so no amount exists."""
    arm(ctx, [{"line": "LAYS CLASSIC", "name": "potato chips", "quantity": 6, "unit": "pcs"}])

    item = parse_image(client).json()["items"][0]

    assert item["quantity"] is None
    assert item["unit"] is None, "a unit with no amount implies a purchase size"


def test_a_big_receipt_is_capped_at_sixty_items(client, ctx) -> None:
    arm(ctx, [dict(BUTTER, line=f"ITEM {i}", name=f"item {i}") for i in range(80)])

    assert len(parse_image(client).json()["items"]) == 60


# ---- bodies we refuse before spending a call -----------------------------


def test_an_oversized_image_is_refused(client, ctx) -> None:
    parser = arm(ctx, [BUTTER])
    too_big = PNG + b"0" * (8 * 1024 * 1024)

    response = parse_image(client, image=too_big)

    assert response.status_code == 422
    assert response.json()["error"] == "invalid_payload"
    assert parser.calls == 0, "a refused body must not cost a model call"


def test_bytes_that_are_not_the_declared_format_are_refused(client, ctx) -> None:
    parser = arm(ctx, [BUTTER])

    response = parse_image(client, image=JPEG, mime_type="image/png")

    assert response.status_code == 422
    assert parser.calls == 0


def test_broken_base64_is_refused(client, ctx) -> None:
    parser = arm(ctx, [BUTTER])

    response = parse_image(client, image_base64="not base64 !!!")

    assert response.status_code == 422
    assert parser.calls == 0


@pytest.mark.parametrize("mime", ["image/gif", "image/heic", "application/pdf"])
def test_an_unsupported_format_is_refused(mime) -> None:
    from shoku_api.schemas import PantryParseImageRequest

    with pytest.raises(Exception):
        PantryParseImageRequest(
            request_id="img-00000001", mime_type=mime, image_base64=b64(PNG)
        )


# ---- the shared allowance -------------------------------------------------


def test_the_image_endpoint_shares_the_text_budget(client, ctx) -> None:
    """A receipt is one unit whichever way it arrives."""
    ctx.pantry_parser = __import__(
        "shoku_api.pantry_parse", fromlist=["FakePantryParser"]
    ).FakePantryParser(
        items=[{"line": "AMUL BUTTER 500G", "name": "butter", "quantity": 500, "unit": "g"}]
    )
    arm(ctx, [BUTTER])

    assert parse_image(client).json()["remaining"] == 2  # cap is 3 in test settings
    assert client.post(
        "/v1/pantry/parse",
        json={"request_id": "text-00000001", "lines": ["AMUL BUTTER 500G"]},
    ).json()["remaining"] == 1
    assert parse_image(client).json()["remaining"] == 0

    over = client.post(
        "/v1/pantry/parse",
        json={"request_id": "text-00000002", "lines": ["AMUL BUTTER 500G"]},
    )
    assert over.status_code == 429
    assert over.json()["error"] == "daily_cap_reached"
    assert over.json()["reset_at"]


def test_a_retried_request_id_is_metered_once(client, ctx) -> None:
    arm(ctx, [BUTTER])

    first = parse_image(client, request_id="retry-image-01").json()
    second = parse_image(client, request_id="retry-image-01").json()

    assert first["remaining"] == second["remaining"] == 2


def test_a_failed_vision_call_releases_the_reservation(client, ctx) -> None:
    class BrokenParser:
        name = "broken"

        def parse_image(self, mime_type, image_base64):
            raise Unavailable(detail="upstream is down")

    ctx.pantry_image_parser = BrokenParser()
    assert parse_image(client).status_code == 503

    arm(ctx, [BUTTER])
    assert parse_image(client).json()["remaining"] == 2, "a failed call is not charged"


def test_parse_image_requires_an_identity(anonymous: TestClient) -> None:
    response = anonymous.post(
        "/v1/pantry/parse-image",
        json={"request_id": "anon-0001", "mime_type": "image/png", "image_base64": b64(PNG)},
    )
    assert response.status_code == 401

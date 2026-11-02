"""The assistant answers in the reader's language; the ops stay English.

The locale never reaches the response, and never reaches an op. What it changes
is one line in front of the system prompt, so the tests assert on what the model
was handed rather than on the model's prose, which no test can pin down.
"""

import itertools

import pytest
from fastapi.testclient import TestClient

from shoku_api.assistant import AssistantContext, FakeAssistantModel, MuseAssistant
from shoku_api.domain.locale import LOCALES, from_header, resolve

_requests = itertools.count(1)


def ask(client: TestClient, *, header: str | None = None, **overrides) -> dict:
    payload = {
        "scope": "dish",
        "dish_id": "dish-1",
        "question": "how do i know it is done?",
        "request_id": f"i18n-{next(_requests):08d}",
    }
    payload.update(overrides)
    headers = {"Accept-Language": header} if header else {}
    response = client.post("/v1/assistant/ask", json=payload, headers=headers)
    assert response.status_code == 200, response.text
    return response.json()


def seed(client, dish_payload, version_payload) -> None:
    client.post(
        "/v1/sync/push",
        json={"dishes": [dish_payload()], "versions": [version_payload()]},
    )


# ---- the mapping ----------------------------------------------------------


def test_every_shipped_locale_has_a_name() -> None:
    assert set(LOCALES) == {"en", "es", "fr", "pt", "id", "hi", "mr", "bn", "ta", "te"}
    assert LOCALES["hi"] == "Hindi"


def test_a_region_tag_falls_back_to_its_language() -> None:
    assert from_header("pt-BR") == "Portuguese"
    assert from_header("es-MX,es;q=0.9") == "Spanish"


def test_an_unknown_tag_is_english() -> None:
    assert from_header("de-DE") is None
    assert resolve(body_locale=None, accept_language="de-DE") == "English"
    assert resolve(body_locale=None, accept_language=None) == "English"


def test_the_body_wins_over_the_header() -> None:
    assert resolve(body_locale="fr", accept_language="es") == "French"
    # An explicit unknown locale is still explicit: it does not fall back to a
    # header some proxy added.
    assert resolve(body_locale="de", accept_language="es") == "English"


# ---- through the endpoint -------------------------------------------------


def test_the_header_is_honoured_in_dish_scope(
    client, ctx, assistant, dish_payload, version_payload
) -> None:
    seed(client, dish_payload, version_payload)

    ask(client, header="es")

    assert assistant.last_context is not None
    assert assistant.last_context.language == "Spanish"


def test_the_body_locale_overrides_the_header(
    client, ctx, assistant, dish_payload, version_payload
) -> None:
    seed(client, dish_payload, version_payload)

    ask(client, header="es", locale="hi")

    assert assistant.last_context.language == "Hindi"


def test_an_unknown_locale_answers_in_english(
    client, ctx, assistant, dish_payload, version_payload
) -> None:
    seed(client, dish_payload, version_payload)

    ask(client, header="de-DE")

    assert assistant.last_context.language == "English"


def test_no_header_at_all_is_english(
    client, ctx, assistant, dish_payload, version_payload
) -> None:
    seed(client, dish_payload, version_payload)

    ask(client)

    assert assistant.last_context.language == "English", "unchanged behaviour"


def test_the_kitchen_scope_passes_it_through_too(client, ctx) -> None:
    ctx.assistant_model = FakeAssistantModel()

    response = client.post(
        "/v1/assistant/ask",
        json={
            "scope": "kitchen",
            "question": "what can i cook?",
            "request_id": "i18n-kitchen-0001",
        },
        headers={"Accept-Language": "ta-IN,ta;q=0.9"},
    )

    assert response.status_code == 200
    assert ctx.assistant_model.last_context.language == "Tamil"


def test_the_locale_never_appears_in_the_response(
    client, ctx, assistant, dish_payload, version_payload
) -> None:
    seed(client, dish_payload, version_payload)

    body = ask(client, header="es", locale="es")

    assert "locale" not in body
    assert "language" not in body


# ---- what the model is actually told --------------------------------------


def test_the_system_prompt_opens_with_the_language(monkeypatch) -> None:
    captured: dict = {}

    class Response:
        def raise_for_status(self):
            return None

        def json(self):
            return {
                "choices": [
                    {
                        "message": {
                            "content": '{"intent":"answer","answer":"ok","ops":[],'
                            '"picks":[],"items":[],"dish_titles":[]}'
                        }
                    }
                ]
            }

    def fake_post(url, **kwargs):
        captured.update(kwargs["json"])
        return Response()

    monkeypatch.setattr("httpx.post", fake_post)
    model = MuseAssistant("https://api.meta.ai/v1", "k", "muse-spark-1.3")

    model.respond(
        AssistantContext(dish_title="Paneer", language="Spanish"), "salt?", ()
    )

    system = captured["messages"][0]["content"]
    assert system.startswith("Answer in Spanish. ")
    assert "The recipe operation vocabulary stays English." in system
    assert "kitchen" in system, "the English instructions are still underneath"


def test_the_operation_vocabulary_is_untouched(monkeypatch) -> None:
    """Localisation must not reach the ops: they are a wire contract."""
    captured: dict = {}

    class Response:
        def raise_for_status(self):
            return None

        def json(self):
            return {
                "choices": [
                    {
                        "message": {
                            "content": '{"intent":"edit","answer":"ok",'
                            '"ops":[{"op":"add_ingredient","index":1,"text":"1 tsp salt",'
                            '"ingredient_indices":null}],'
                            '"picks":[],"items":[],"dish_titles":[]}'
                        }
                    }
                ]
            }

    def fake_post(url, **kwargs):
        captured.update(kwargs["json"])
        return Response()

    monkeypatch.setattr("httpx.post", fake_post)
    model = MuseAssistant("https://api.meta.ai/v1", "k", "muse-spark-1.3")

    turn = model.respond(
        AssistantContext(dish_title="Paneer", language="Hindi"), "add salt", ()
    )

    assert turn.intent == "edit"
    assert turn.ops[0]["op"] == "add_ingredient", "the whitelist stays English"
    schema = captured["response_format"]["json_schema"]["schema"]
    assert "add_ingredient" in schema["properties"]["ops"]["items"]["properties"]["op"]["enum"]


@pytest.mark.parametrize("tag,name", [("en", "English"), ("bn", "Bengali"), ("te", "Telugu")])
def test_the_ten_locales_round_trip(client, ctx, assistant, dish_payload, version_payload, tag, name) -> None:
    seed(client, dish_payload, version_payload)

    ask(client, locale=tag, request_id=f"i18n-{tag}-00001")

    assert assistant.last_context.language == name

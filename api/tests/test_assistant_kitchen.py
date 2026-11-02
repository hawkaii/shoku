"""The kitchen scope: no dish open, and no way to write to one.

The two things worth defending here are that a suggestion can only be a card the
server computed, and that capture never invents an amount. Both are enforced
server-side, so the tests hand the model a deliberately dishonest answer.
"""

import itertools
from datetime import datetime, timezone

from fastapi.testclient import TestClient

from shoku_api.assistant import AssistantTurn, FakeAssistantModel
from shoku_api.models import ContentCache, Dish, PantryItem, RecipeVersion

_requests = itertools.count(1)


def kitchen(client: TestClient, question="what can i cook?", **overrides):
    payload = {
        "scope": "kitchen",
        "question": question,
        "request_id": f"kitchen-{next(_requests):08d}",
    }
    payload.update(overrides)
    return client.post("/v1/assistant/ask", json=payload)


def add_card(session, shortcode, ingredients) -> None:
    session.add(
        ContentCache(
            shortcode=shortcode,
            structured_json={
                "title": f"Card {shortcode}",
                "servings": 2,
                "minutes": 20,
                "kcal": 0,
                "protein": 0,
                "ingredients": [{"name": n, "amount": None, "grams": None} for n in ingredients],
                "steps": ["Cook."],
                "tags": [],
            },
            prose_json={"summary": ""},
            creator="Ravi",
            creator_handle="@ravi",
            platform="instagram",
            thumbnail_url="https://media.test/cover.jpg",
            source_url=f"https://www.instagram.com/reel/{shortcode}/",
            extraction_version=4,
            created_at=datetime(2026, 10, 1, tzinfo=timezone.utc),
        )
    )


def add_pantry(session, uid, name, *, quantity=None, unit=None, wanted=False) -> None:
    session.add(
        PantryItem(
            id=f"{uid}-{name}",
            user_id=uid,
            name=name,
            quantity=quantity,
            unit=unit,
            aliases=[],
            wanted=wanted,
            source="typed",
            created_at=datetime(2026, 1, 1, tzinfo=timezone.utc),
            updated_at=datetime(2026, 1, 1, tzinfo=timezone.utc),
        )
    )


def seed_corpus(session) -> None:
    """One card above the coverage floor, one below it."""
    add_card(session, "pass1234567", ["salt", "butter", "onion", "ghee", "a", "b"])  # 4/6
    add_card(session, "drop1234567", ["salt", "x1", "x2", "x3", "x4"])  # 1/5
    for name in ["salt", "butter", "onion", "ghee"]:
        add_pantry(session, "user-1", name)
    session.commit()


# ---- request shape --------------------------------------------------------


def test_kitchen_may_not_name_a_dish(client) -> None:
    response = kitchen(client, dish_id="dish-1")
    assert response.status_code == 422


def test_a_dish_question_needs_a_dish(client) -> None:
    response = client.post(
        "/v1/assistant/ask",
        json={"scope": "dish", "question": "salt?", "request_id": "no-dish-0001"},
    )
    assert response.status_code == 422


def test_step_index_only_means_something_with_a_dish(client) -> None:
    response = kitchen(client, step_index=2)
    assert response.status_code == 422


def test_scope_is_required(client) -> None:
    response = client.post(
        "/v1/assistant/ask",
        json={"dish_id": "dish-1", "question": "salt?", "request_id": "no-scope-001"},
    )
    assert response.status_code == 422


# ---- suggest --------------------------------------------------------------


def test_suggest_returns_only_candidates_above_the_floor(client, ctx, session) -> None:
    seed_corpus(session)
    ctx.assistant_model = FakeAssistantModel(
        AssistantTurn(
            "suggest",
            "You could make this.",
            picks=("pass1234567", "drop1234567", "invented01"),
        )
    )

    body = kitchen(client).json()

    assert body["intent"] == "suggest"
    assert [item["shortcode"] for item in body["suggestions"]] == ["pass1234567"]
    suggestion = body["suggestions"][0]
    assert suggestion["have"] == 4
    assert suggestion["total"] == 6
    assert suggestion["missing"] == ["a", "b"]
    assert "invented01" not in str(body), "a card the model made up cannot appear"


def test_a_dish_too_far_below_the_floor_is_never_offered(client, ctx, session) -> None:
    seed_corpus(session)
    ctx.assistant_model = FakeAssistantModel(
        AssistantTurn("suggest", "Try this.", picks=("drop1234567",))
    )

    body = kitchen(client).json()

    assert body["intent"] == "answer", "nothing valid was picked, so it is prose"
    assert body["suggestions"] == []


def test_exclude_puts_the_next_candidate_in_front(client, ctx, session) -> None:
    add_card(session, "best1234567", ["salt", "butter"])  # 2/2
    add_card(session, "next1234567", ["salt", "x1"])  # 1/2
    add_pantry(session, "user-1", "salt")
    add_pantry(session, "user-1", "butter")
    session.commit()

    parser = ctx.assistant_model = FakeAssistantModel(
        AssistantTurn("suggest", "Next best.", picks=("next1234567",))
    )

    body = kitchen(client, exclude=["best1234567"]).json()

    assert [s["shortcode"] for s in body["suggestions"]] == ["next1234567"]
    assert "best1234567" not in [c["shortcode"] for c in parser.last_context.candidates]


def test_an_empty_pantry_suggests_nothing(client, ctx, session) -> None:
    add_card(session, "pass1234567", ["salt", "butter"])
    session.commit()
    ctx.assistant_model = FakeAssistantModel(
        AssistantTurn("suggest", "Nothing yet.", picks=("pass1234567",))
    )

    body = kitchen(client).json()

    assert body["intent"] == "answer"
    assert body["suggestions"] == []


# ---- capture --------------------------------------------------------------


def test_capture_parses_an_amount_and_a_unit(client, ctx) -> None:
    ctx.assistant_model = FakeAssistantModel(
        AssistantTurn(
            "capture",
            "Added those.",
            items=(
                {"name": "rice", "quantity": 2, "unit": "kg"},
                {"name": "paneer", "quantity": None, "unit": None},
            ),
        )
    )

    body = kitchen(client, "I have 2 kg rice and paneer").json()

    assert body["intent"] == "capture"
    assert body["items"] == [
        {"name": "rice", "quantity": 2.0, "unit": "kg"},
        {"name": "paneer", "quantity": None, "unit": None},
    ]


def test_capture_refuses_an_amount_the_message_never_stated(client, ctx) -> None:
    ctx.assistant_model = FakeAssistantModel(
        AssistantTurn(
            "capture",
            "Added.",
            items=({"name": "rice", "quantity": 5, "unit": "kg"},),
        )
    )

    item = kitchen(client, "I have rice").json()["items"][0]

    assert item["quantity"] is None, "no digit in the message, so no amount exists"
    assert item["unit"] is None


def test_capture_rejects_an_unknown_unit(client, ctx) -> None:
    ctx.assistant_model = FakeAssistantModel(
        AssistantTurn(
            "capture",
            "Added.",
            items=({"name": "rice", "quantity": 2, "unit": "cups"},),
        )
    )

    item = kitchen(client, "I have 2 cups of rice").json()["items"][0]

    assert item["unit"] is None
    assert item["quantity"] == 2.0, "the amount survives; only the unit is refused"


def test_capture_with_no_usable_items_is_an_answer(client, ctx) -> None:
    ctx.assistant_model = FakeAssistantModel(
        AssistantTurn("capture", "Hmm.", items=({"name": "", "quantity": 1, "unit": "kg"},))
    )

    body = kitchen(client, "I have 1 kg of something").json()

    assert body["intent"] == "answer"
    assert body["items"] == []


# ---- it never edits -------------------------------------------------------


def test_kitchen_never_returns_an_edit(client, ctx, session, dish_payload, version_payload) -> None:
    client.post(
        "/v1/sync/push",
        json={"dishes": [dish_payload()], "versions": [version_payload()]},
    )
    ctx.assistant_model = FakeAssistantModel(
        AssistantTurn(
            "edit",
            "Added salt.",
            ops=({"op": "add_ingredient", "index": 1, "text": "1 tsp salt"},),
        )
    )
    before = client.post("/v1/sync/pull", json={}).json()

    body = kitchen(client, "add salt to the paneer").json()

    assert body["intent"] == "answer"
    assert body["appliable"] is None
    assert body["edits"] == []
    assert client.post("/v1/sync/pull", json={}).json()["versions"] == before["versions"]


# ---- clarify --------------------------------------------------------------


def test_a_clarify_can_offer_the_users_own_dishes(
    client, ctx, dish_payload, version_payload
) -> None:
    client.post(
        "/v1/sync/push",
        json={"dishes": [dish_payload()], "versions": [version_payload()]},
    )
    ctx.assistant_model = FakeAssistantModel(
        AssistantTurn("clarify", "Which dish?", dish_titles=("Paneer", "Invented Dish"))
    )

    body = kitchen(client, "add salt").json()

    assert body["intent"] == "clarify"
    assert body["choices"] == [{"dish_id": "dish-1", "title": "Paneer"}]


# ---- cap ------------------------------------------------------------------


def test_a_kitchen_ask_spends_the_same_talk_budget(client, ctx) -> None:
    ctx.assistant_model = FakeAssistantModel(AssistantTurn("answer", "Nothing yet."))

    first = kitchen(client).json()
    assert first["remaining"] == 2  # cap is 3 in test settings

    second = kitchen(client, request_id="kitchen-replay-1").json()
    assert second["remaining"] == 1

    replay = kitchen(client, request_id="kitchen-replay-1").json()
    assert replay["remaining"] == 1, "a retried kitchen ask is still one talk"

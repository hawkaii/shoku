"""The assistant: scoped, capped, and structurally unable to write recipes.

The tests that matter most are the negative ones — an ask must not create a
version, must not apply an op it cannot resolve, and must not charge for a call
that failed. The positive ones pin the shape the client applies.
"""

import itertools
from datetime import datetime, timedelta, timezone

from fastapi.testclient import TestClient

from shoku_api.assistant import AssistantTurn, FakeAssistantModel
from shoku_api.domain.errors import Unavailable
from shoku_api.models import ContentCache

_requests = itertools.count(1)


def ask(client: TestClient, **overrides):
    payload = {
        "scope": "dish",
        "dish_id": "dish-1",
        "question": "How do I know when it is done?",
        "request_id": f"req-{next(_requests):08d}",
    }
    payload.update(overrides)
    return client.post("/v1/assistant/ask", json=payload)


def seed(client: TestClient, dish_payload, version_payload) -> None:
    response = client.post(
        "/v1/sync/push",
        json={"dishes": [dish_payload()], "versions": [version_payload()]},
    )
    assert response.status_code == 200


def seed_with_links(client, session, dish_payload, version_payload, shortcode="DctNWIDT540"):
    """A version whose extraction carries step links, so edits have links to shift."""
    client.post(
        "/v1/sync/push",
        json={
            "dishes": [dish_payload()],
            "versions": [
                version_payload(
                    ingredients=["250 g paneer", "2 tbsp butter"],
                    steps=["Fry the paneer.", "Add the butter."],
                    origin_kind="import",
                    origin_shortcode=shortcode,
                    origin_url=f"https://www.instagram.com/reel/{shortcode}/",
                )
            ],
        },
    )
    session.add(
        ContentCache(
            shortcode=shortcode,
            structured_json={
                "title": "Paneer",
                "servings": 2,
                "minutes": 10,
                "kcal": 0,
                "protein": 0,
                "ingredients": [{"name": "paneer"}, {"name": "butter"}],
                "steps": ["Fry the paneer.", "Add the butter."],
                "tags": [],
                "step_ingredients": [[0], [1]],
            },
            prose_json={"summary": ""},
            source_url=f"https://www.instagram.com/reel/{shortcode}/",
            extraction_version=4,
            created_at=datetime.now(timezone.utc),
        )
    )
    session.commit()


# ---- the cap --------------------------------------------------------------


def test_daily_cap_is_enforced(client, dish_payload, version_payload) -> None:
    seed(client, dish_payload, version_payload)

    codes = [ask(client).status_code for _ in range(4)]  # cap is 3 in test settings
    assert codes == [200, 200, 200, 429]

    body = ask(client).json()
    assert body["error"] == "daily_cap_reached"
    assert body["reset_at"]


def test_remaining_decreases(client, dish_payload, version_payload) -> None:
    seed(client, dish_payload, version_payload)
    assert ask(client).json()["remaining"] == 2
    assert ask(client).json()["remaining"] == 1
    assert ask(client).json()["remaining"] == 0


def test_cap_is_per_user(client, app, dish_payload, version_payload) -> None:
    seed(client, dish_payload, version_payload)
    for _ in range(3):
        assert ask(client).status_code == 200
    assert ask(client).status_code == 429

    with TestClient(app) as other:
        other.headers.update({"X-Firebase-Uid": "user-2"})
        other.post(
            "/v1/sync/push",
            json={
                "dishes": [dish_payload(id="dish-2")],
                "versions": [version_payload(id="v2", dish_id="dish-2")],
            },
        )
        assert ask(other, dish_id="dish-2").status_code == 200


def test_reset_at_is_the_next_midnight_utc(client, dish_payload, version_payload) -> None:
    seed(client, dish_payload, version_payload)

    body = ask(client).json()
    reset = datetime.fromisoformat(body["reset_at"].replace("Z", "+00:00"))
    assert (reset.hour, reset.minute, reset.second, reset.microsecond) == (0, 0, 0, 0)
    assert reset.tzinfo is not None
    assert timedelta(0) < reset - datetime.now(timezone.utc) <= timedelta(days=1)

    for _ in range(3):
        ask(client)
    capped = ask(client).json()
    assert capped["reset_at"], "a 429 must say when the cap lifts"


def test_a_retried_request_id_is_metered_once(client, dish_payload, version_payload) -> None:
    seed(client, dish_payload, version_payload)

    first = ask(client, request_id="retry-me-0001").json()
    second = ask(client, request_id="retry-me-0001").json()

    assert first["remaining"] == second["remaining"], "a retry is not a second ask"
    assert second["remaining"] == 2


def test_the_cap_is_shared_across_intents(client, ctx, dish_payload, version_payload) -> None:
    seed(client, dish_payload, version_payload)

    assert ask(client).json()["remaining"] == 2  # an answer

    ctx.assistant_model = FakeAssistantModel(
        AssistantTurn("edit", "Added butter.", ({"op": "add_ingredient", "index": 1, "text": "1 tsp salt"},))
    )
    assert ask(client, question="add salt").json()["remaining"] == 1  # an edit


# ---- it never writes journal rows -----------------------------------------


def test_assistant_never_mutates_the_recipe(client, dish_payload, version_payload) -> None:
    seed(client, dish_payload, version_payload)
    before = client.post("/v1/sync/pull", json={}).json()

    assert ask(client).status_code == 200

    after = client.post("/v1/sync/pull", json={}).json()
    assert after["dishes"] == before["dishes"]
    assert after["versions"] == before["versions"]


def test_an_edit_writes_no_version_either(client, ctx, dish_payload, version_payload) -> None:
    """Fork-vs-not: the ask returns arrays, the client applies them."""
    seed(client, dish_payload, version_payload)
    ctx.assistant_model = FakeAssistantModel(
        AssistantTurn("edit", "Added salt.", ({"op": "add_ingredient", "index": 1, "text": "1 tsp salt"},))
    )
    before = client.post("/v1/sync/pull", json={}).json()

    body = ask(client, question="add salt").json()

    after = client.post("/v1/sync/pull", json={}).json()
    assert body["intent"] == "edit"
    assert after["versions"] == before["versions"], "only the client may create a version"


def test_a_failed_model_call_does_not_consume_quota(
    client, ctx, dish_payload, version_payload
) -> None:
    seed(client, dish_payload, version_payload)

    class BrokenModel:
        name = "broken"

        def respond(self, context, question, history):
            raise Unavailable(detail="upstream is down")

    ctx.assistant_model = BrokenModel()
    assert ask(client).status_code == 503

    ctx.assistant_model = FakeAssistantModel()
    body = ask(client).json()
    assert body["remaining"] == 2, "the user was not charged for a failed call"


def test_a_failed_call_releases_its_request_id(client, ctx, dish_payload, version_payload) -> None:
    """A retry after a failure must be able to spend the unit it did not use."""
    seed(client, dish_payload, version_payload)

    class BrokenModel:
        name = "broken"

        def respond(self, context, question, history):
            raise Unavailable(detail="upstream is down")

    ctx.assistant_model = BrokenModel()
    assert ask(client, request_id="retry-after-fail").status_code == 503

    ctx.assistant_model = FakeAssistantModel()
    assert ask(client, request_id="retry-after-fail").json()["remaining"] == 2


# ---- edits ----------------------------------------------------------------


def test_an_edit_returns_edits_and_appliable(client, ctx, dish_payload, version_payload) -> None:
    seed(client, dish_payload, version_payload)
    ctx.assistant_model = FakeAssistantModel(
        AssistantTurn(
            "edit",
            "Added potatoes.",
            ({"op": "add_ingredient", "index": 1, "text": "2 potatoes, cubed"},),
        )
    )

    body = ask(client, question="i want to add potato").json()

    assert body["intent"] == "edit"
    assert body["edits"] == [
        {
            "op": "add",
            "field": "ingredients",
            "index": 1,
            "text": "2 potatoes, cubed",
            "previous": None,
        }
    ]
    appliable = body["appliable"]
    assert appliable["ingredients"] == ["250 g paneer", "2 potatoes, cubed"]
    assert appliable["steps"] == ["Fry"]
    assert appliable["changes"] == ["Added 2 potatoes, cubed"]
    assert appliable["base_version_id"] == "v1"


def test_an_edit_that_shifts_indices_shifts_the_links(
    client, ctx, session, dish_payload, version_payload
) -> None:
    """An ingredient inserted first renumbers every citation behind it."""
    seed_with_links(client, session, dish_payload, version_payload)
    ctx.assistant_model = FakeAssistantModel(
        AssistantTurn(
            "edit",
            "Added cumin.",
            ({"op": "add_ingredient", "index": 0, "text": "1 tsp cumin seeds"},),
        )
    )

    body = ask(client, question="add cumin first").json()

    assert body["appliable"]["ingredients"][0] == "1 tsp cumin seeds"
    assert body["appliable"]["step_ingredients"] == [[1], [2]], "links follow the shift"


def test_appliable_is_computed_against_the_head_not_the_viewed_version(
    client, ctx, dish_payload, version_payload
) -> None:
    client.post(
        "/v1/sync/push",
        json={
            "dishes": [dish_payload()],
            "versions": [
                version_payload(id="v1", number=1, created_at="2026-01-01T10:00:00Z"),
                version_payload(
                    id="v2",
                    number=2,
                    ingredients=["250 g paneer", "1 tbsp ghee"],
                    created_at="2026-02-01T10:00:00Z",
                ),
            ],
        },
    )
    ctx.assistant_model = FakeAssistantModel(
        AssistantTurn("edit", "Added salt.", ({"op": "add_ingredient", "index": 2, "text": "1 tsp salt"},))
    )

    body = ask(client, version_id="v1", question="add salt").json()

    assert body["appliable"]["base_version_id"] == "v2", "edits land on the head"
    assert body["appliable"]["ingredients"][-1] == "1 tsp salt"


def test_an_unresolvable_target_is_a_clarify_not_a_write(
    client, ctx, dish_payload, version_payload
) -> None:
    seed(client, dish_payload, version_payload)
    ctx.assistant_model = FakeAssistantModel(
        AssistantTurn("edit", "Removed it.", ({"op": "remove_ingredient", "index": 9},))
    )
    before = client.post("/v1/sync/pull", json={}).json()

    body = ask(client, question="remove the last thing").json()

    assert body["intent"] == "clarify"
    assert body["appliable"] is None
    assert body["edits"] == []
    assert client.post("/v1/sync/pull", json={}).json()["versions"] == before["versions"]


def test_an_invalid_op_is_an_answer_not_a_write(
    client, ctx, dish_payload, version_payload
) -> None:
    seed(client, dish_payload, version_payload)
    ctx.assistant_model = FakeAssistantModel(
        AssistantTurn("edit", "Done.", ({"op": "retitle_dish", "index": 0, "text": "New name"},))
    )

    body = ask(client, question="rename it").json()

    assert body["intent"] == "clarify"
    assert body["appliable"] is None


# ---- scope ----------------------------------------------------------------


def test_assistant_sees_the_scoped_version(
    client, dish_payload, version_payload, assistant
) -> None:
    seed(client, dish_payload, version_payload)
    ask(client, version_id="v1")

    context = assistant.last_context
    assert context is not None
    assert context.dish_title == "Paneer"
    assert context.ingredients == ("250 g paneer",)
    assert context.steps == ("Fry",)


def test_cannot_ask_about_someone_elses_dish(
    client, app, dish_payload, version_payload
) -> None:
    seed(client, dish_payload, version_payload)

    with TestClient(app) as other:
        other.headers.update({"X-Firebase-Uid": "user-2"})
        response = other.post(
            "/v1/assistant/ask",
            json={
                "scope": "dish",
                "dish_id": "dish-1",
                "question": "What is in this?",
                "request_id": "other-user-0001",
            },
        )
    assert response.status_code == 404

"""The assistant: scoped, capped, and structurally unable to write recipes."""

from fastapi.testclient import TestClient

from shoku_api.assistant import FakeAssistantModel
from shoku_api.domain.errors import Unavailable


def ask(client: TestClient, **overrides):
    payload = {"dish_id": "dish-1", "question": "How do I know when it is done?"}
    payload.update(overrides)
    return client.post("/v1/assistant/ask", json=payload)


def seed(client: TestClient, dish_payload, version_payload) -> None:
    response = client.post(
        "/v1/sync/push",
        json={"dishes": [dish_payload()], "versions": [version_payload()]},
    )
    assert response.status_code == 200


def test_daily_cap_is_enforced(client, dish_payload, version_payload) -> None:
    seed(client, dish_payload, version_payload)

    codes = [ask(client).status_code for _ in range(4)]  # cap is 3 in test settings
    assert codes == [200, 200, 200, 429]

    body = ask(client).json()
    assert body["error"] == "daily_cap_reached"


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


def test_assistant_never_mutates_the_recipe(
    client, dish_payload, version_payload
) -> None:
    seed(client, dish_payload, version_payload)
    before = client.post("/v1/sync/pull", json={}).json()

    assert ask(client).status_code == 200

    after = client.post("/v1/sync/pull", json={}).json()
    assert after["dishes"] == before["dishes"]
    assert after["versions"] == before["versions"]


def test_assistant_sees_only_the_scoped_version(
    client, dish_payload, version_payload, assistant
) -> None:
    seed(client, dish_payload, version_payload)
    ask(client, version_id="v1")

    context = assistant.last_context
    assert context is not None
    assert context.dish_title == "Paneer"
    assert context.ingredients == ("250 g paneer",)
    assert context.version_number == 1


def test_cannot_ask_about_someone_elses_dish(
    client, app, dish_payload, version_payload
) -> None:
    seed(client, dish_payload, version_payload)

    with TestClient(app) as other:
        other.headers.update({"X-Firebase-Uid": "user-2"})
        response = other.post(
            "/v1/assistant/ask",
            json={"dish_id": "dish-1", "question": "What is in this?"},
        )
    assert response.status_code == 404


def test_a_failed_model_call_does_not_consume_quota(
    client, ctx, dish_payload, version_payload
) -> None:
    seed(client, dish_payload, version_payload)

    class BrokenModel:
        def answer(self, context, question):
            raise Unavailable(detail="upstream is down")

    ctx.assistant_model = BrokenModel()
    assert ask(client).status_code == 503

    ctx.assistant_model = FakeAssistantModel()
    body = ask(client).json()
    assert body["remaining"] == 2, "the user was not charged for a failed call"

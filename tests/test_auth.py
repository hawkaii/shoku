"""Auth, health and photo presigning."""

from fastapi.testclient import TestClient


def test_health_reports_its_dependencies(client: TestClient) -> None:
    body = client.get("/health").json()
    assert body["status"] == "ok"
    assert body["database"] is True
    assert body["queue"] is True
    assert body["version"]


def test_missing_token_is_rejected(anonymous: TestClient) -> None:
    response = anonymous.post("/v1/sync/pull", json={})
    assert response.status_code == 401
    assert response.json()["error"] == "unauthenticated"


def test_blank_token_is_rejected(anonymous: TestClient) -> None:
    response = anonymous.get("/health", headers={"X-Firebase-Uid": "   "})
    # /health is public; a protected route is not.
    assert response.status_code == 200

    protected = anonymous.post("/v1/sync/pull", json={}, headers={"X-Firebase-Uid": ""})
    assert protected.status_code == 401


def test_identity_is_the_firebase_uid(client: TestClient, session, dish_payload) -> None:
    from shoku_api.models import User

    client.post("/v1/sync/push", json={"dishes": [dish_payload()]})
    assert session.get(User, "user-1") is not None
    assert session.get(User, "user-2") is None


def test_presign_is_namespaced_to_the_caller(client: TestClient, storage) -> None:
    response = client.post("/v1/photos/presign", json={"content_type": "image/jpeg"})
    assert response.status_code == 200

    body = response.json()
    assert body["method"] == "PUT"
    assert body["key"].startswith("photos/user-1/")
    assert body["key"].endswith(".jpg")
    assert body["upload_url"].startswith("https://")
    assert body["expires_in"] > 0
    assert storage.keys == [body["key"]]


def test_presign_rejects_a_non_image_type(client: TestClient) -> None:
    response = client.post("/v1/photos/presign", json={"content_type": "text/html"})
    assert response.status_code == 422


def test_presign_rejects_path_traversal_in_the_extension(client: TestClient) -> None:
    response = client.post(
        "/v1/photos/presign", json={"content_type": "image/png", "extension": "../../etc"}
    )
    assert response.status_code == 422


def test_each_user_gets_their_own_namespace(app) -> None:
    with TestClient(app) as alice, TestClient(app) as bob:
        alice.headers.update({"X-Firebase-Uid": "alice"})
        bob.headers.update({"X-Firebase-Uid": "bob"})

        a = alice.post("/v1/photos/presign", json={}).json()["key"]
        b = bob.post("/v1/photos/presign", json={}).json()["key"]

    assert a.startswith("photos/alice/")
    assert b.startswith("photos/bob/")

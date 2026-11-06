"""Account deletion: the floor under Play's data-deletion requirement.

Every table with a ``user_id`` must be gone afterwards, and so must the photo
objects, because the row is the only record of their keys. What survives is the
Wall entry for a reel — that belongs to the creator being cached, not to the
person who asked to be erased.
"""

from __future__ import annotations

from datetime import datetime, timezone

from fastapi.testclient import TestClient
from sqlalchemy import func, select

from shoku_api.models import CookLog, Dish, PantryItem, Photo, RecipeVersion


def _seed(ctx) -> None:
    now = datetime(2026, 11, 6, tzinfo=timezone.utc)
    with ctx.session_factory() as session:
        session.add(
            Dish(
                id="d1",
                user_id="user-1",
                title="Paneer",
                status="cooked",
                steps=[],
                created_at=now,
                updated_at=now,
            )
        )
        session.add(
            RecipeVersion(
                id="v1",
                user_id="user-1",
                dish_id="d1",
                number=0,
                changes=[],
                ingredients=["paneer"],
                steps=["cook"],
                kcal=0,
                protein=0,
                origin_kind="mine",
                extraction_version=1,
                created_at=now,
            )
        )
        session.add(
            CookLog(
                id="c1",
                user_id="user-1",
                dish_id="d1",
                version_number=0,
                cooked_at=now,
                outcome="good",
                mood="happy",
            )
        )
        session.add(
            PantryItem(id="p1", user_id="user-1", name="rice", created_at=now, updated_at=now)
        )
        session.add(
            Photo(id="ph1", user_id="user-1", version_id="v1", key="user-1/v1/a.jpg")
        )
        session.commit()


def _counts(ctx) -> dict[str, int]:
    with ctx.session_factory() as session:
        return {
            "dishes": session.scalar(select(func.count()).select_from(Dish)) or 0,
            "versions": session.scalar(select(func.count()).select_from(RecipeVersion)) or 0,
            "cooks": session.scalar(select(func.count()).select_from(CookLog)) or 0,
            "pantry": session.scalar(select(func.count()).select_from(PantryItem)) or 0,
            "photos": session.scalar(select(func.count()).select_from(Photo)) or 0,
        }


def test_deleting_an_account_erases_every_row_and_its_photos(client, ctx) -> None:
    _seed(ctx)
    assert _counts(ctx)["dishes"] == 1

    response = client.delete("/v1/account")

    assert response.status_code == 204, response.text
    assert _counts(ctx) == {
        "dishes": 0,
        "versions": 0,
        "cooks": 0,
        "pantry": 0,
        "photos": 0,
    }
    assert ctx.storage.deleted == ["user-1/v1/a.jpg"], "the object goes with the row"


def test_the_journal_is_empty_afterwards(client, ctx) -> None:
    _seed(ctx)
    client.delete("/v1/account")

    pull = client.post("/v1/sync/pull", json={})
    assert pull.status_code == 200, pull.text
    body = pull.json()
    assert body["dishes"] == []
    assert body["versions"] == []
    assert body["cook_logs"] == []


def test_deleting_twice_is_harmless(client, ctx) -> None:
    _seed(ctx)
    assert client.delete("/v1/account").status_code == 204
    # The token still resolves; asking again creates a fresh empty account and
    # erases that, rather than failing with a 500.
    assert client.delete("/v1/account").status_code == 204

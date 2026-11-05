"""The pool's HTTP fallback, for a tenant with no Redis path.

Neither tenant uses this today: both share the board's Redis and talk to it
directly. It exists so a third service can join without demanding a Redis
client, and it speaks the same keys the broker reads — never a second source of
truth.

A caller is identified by the ``tenant`` it names. There is no tenancy check on
this route beyond authentication, because there is no tenant directory yet: a
machine tenant will need a service credential before this is used in anger.
"""

from typing import Annotated

from fastapi import APIRouter, Depends
from pydantic import BaseModel, ConfigDict, StringConstraints
from sqlalchemy.orm import Session

from ..container import AppContext
from ..domain.errors import NotFound, Unavailable
from ..models import User
from .deps import current_user, get_context, get_session

router = APIRouter(prefix="/pool", tags=["pool"])

Tenant = Annotated[str, StringConstraints(min_length=1, max_length=64)]
Pool = Annotated[str, StringConstraints(min_length=1, max_length=64)]


class LeaseRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    tenant: Tenant
    job: Annotated[str, StringConstraints(min_length=1, max_length=128)]


class LeaseReply(BaseModel):
    id: str


class DemandRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    tenant: Tenant
    count: int = 1


class DemandReply(BaseModel):
    count: int


class PoolStatus(BaseModel):
    pool: str
    instances: list[str]
    leases: list[dict]
    demand: int
    idle_seconds: float | None
    broker_alive: bool


def _registry(ctx: AppContext):
    registry = ctx.pool_registry
    if registry is None:
        raise Unavailable(detail="this deployment has no pool registry")
    return registry


@router.post("/{pool}/lease", response_model=LeaseReply)
def take_lease(
    pool: Pool,
    body: LeaseRequest,
    ctx: AppContext = Depends(get_context),
    user: User = Depends(current_user),
) -> LeaseReply:
    lease_id = _registry(ctx).take_lease(
        pool, body.tenant, body.job, host="http", pid=0
    )
    return LeaseReply(id=lease_id)


@router.post("/{pool}/lease/{lease_id}/heartbeat", response_model=LeaseReply)
def heartbeat(
    pool: Pool,
    lease_id: str,
    body: DemandRequest,
    ctx: AppContext = Depends(get_context),
    user: User = Depends(current_user),
) -> LeaseReply:
    if not _registry(ctx).heartbeat(pool, body.tenant, lease_id):
        raise NotFound(detail="no such lease")
    return LeaseReply(id=lease_id)


@router.delete("/{pool}/lease/{lease_id}")
def release_lease(
    pool: Pool,
    lease_id: str,
    tenant: Tenant,
    ctx: AppContext = Depends(get_context),
    user: User = Depends(current_user),
) -> dict:
    _registry(ctx).release(pool, tenant, lease_id)
    return {"released": True}


@router.post("/{pool}/demand", response_model=DemandReply)
def demand(
    pool: Pool,
    body: DemandRequest,
    ctx: AppContext = Depends(get_context),
    user: User = Depends(current_user),
) -> DemandReply:
    return DemandReply(count=_registry(ctx).bump_demand(pool, body.tenant, body.count))


@router.get("/{pool}", response_model=PoolStatus)
def status(
    pool: Pool,
    ctx: AppContext = Depends(get_context),
    user: User = Depends(current_user),
) -> PoolStatus:
    registry = _registry(ctx)
    leases = registry.leases(pool)
    broker = ctx.pool_broker
    instances = [
        name.strip()
        for name in (ctx.settings.pool_instances or ctx.settings.worker_instance).split(",")
        if name.strip()
    ]
    return PoolStatus(
        pool=pool,
        instances=instances,
        leases=[
            {"tenant": lease.tenant, "id": lease.id, "job": lease.job, "ts": lease.ts}
            for lease in leases
        ],
        demand=registry.demand(pool),
        idle_seconds=(
            None
            if broker is None or broker._idle_since is None
            else round(broker.clock() - broker._idle_since, 1)
        ),
        broker_alive=bool(getattr(registry, "_client", None)) and registry._client.exists(
            f"wpool:beat:{pool}"
        ),
    )

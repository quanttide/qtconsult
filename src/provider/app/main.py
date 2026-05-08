from pathlib import Path

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware

from app.auth import verify_token
from app.config import settings
from app.models import Card, CardPatch, Project, Workspace
from app.storage import LocalStorage, S3Storage

app = FastAPI(title="QtConsult Provider", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

FIXTURES_DIR = Path(__file__).resolve().parents[3] / "assets" / "fixtures"

if settings.storage_backend == "s3":
    storage = S3Storage(
        bucket=settings.s3_bucket,
        prefix=settings.s3_prefix,
        region=settings.s3_region,
        endpoint_url=settings.s3_endpoint_url,
        access_key_id=settings.s3_access_key_id,
        secret_access_key=settings.s3_secret_access_key,
        addressing_style=settings.s3_addressing_style,
    )
else:
    storage = LocalStorage(data_dir=settings.data_dir)

workspaces: dict[str, dict[str, Project]] = {}


def _resolve(workspace_id: str, project_id: str) -> Project:
    ws = workspaces.get(workspace_id)
    if ws is None:
        raise HTTPException(status_code=404, detail=f"Workspace '{workspace_id}' not found")
    project = ws.get(project_id)
    if project is None:
        raise HTTPException(status_code=404, detail=f"Project '{project_id}' not found in workspace '{workspace_id}'")
    return project


def _find_card(project: Project, card_id: str) -> Card | None:
    for list_name in ("observe", "orient", "decide", "act"):
        for card in getattr(project.lists, list_name):
            if card.id == card_id:
                return card
    return None


def _find_list(project: Project, card_id: str) -> list[Card] | None:
    for list_name in ("observe", "orient", "decide", "act"):
        items = getattr(project.lists, list_name)
        if any(c.id == card_id for c in items):
            return items
    return None


def _persist(workspace_id: str, project_id: str, project: Project):
    storage.save(workspace_id, project_id, project)


def _load_fixtures() -> dict[str, dict[str, Project]]:
    result: dict[str, dict[str, Project]] = {}
    if not FIXTURES_DIR.is_dir():
        return result
    for ws_dir in sorted(FIXTURES_DIR.iterdir()):
        if not ws_dir.is_dir() or ws_dir.name.startswith("."):
            continue
        wid = ws_dir.name
        projects: dict[str, Project] = {}
        for fixture_path in sorted(ws_dir.glob("*.json")):
            pid = fixture_path.stem
            raw = fixture_path.read_text("utf-8")
            project = Project.model_validate_json(raw)
            if not project.workspace_id:
                project.workspace_id = wid
            projects[pid] = project
        if projects:
            result[wid] = projects
    return result


def _migrate_legacy():
    """Migrate flat data/project1.json to data/workspace1/project1.json."""
    from app.models import Project as ProjectModel
    legacy_path = settings.data_dir / "project1.json"
    if not legacy_path.exists():
        return
    target_path = settings.data_dir / "workspace1" / "project1.json"
    if target_path.exists():
        return
    print(f"[迁移] 检测到旧数据格式 {legacy_path}，正在迁移到 {target_path}")
    raw = legacy_path.read_text("utf-8")
    project = ProjectModel.model_validate_json(raw)
    project.workspace_id = "workspace1"
    target_path.parent.mkdir(parents=True, exist_ok=True)
    target_path.write_text(
        project.model_dump_json(indent=2, exclude_none=True),
        encoding="utf-8",
    )
    backup = legacy_path.with_suffix(".json.bak")
    legacy_path.rename(backup)
    print(f"[迁移] 完成，原文件已备份到 {backup}")


@app.on_event("startup")
def load_data():
    global workspaces
    _migrate_legacy()
    # Always seed from fixtures, then overlay with storage updates
    workspaces = _load_fixtures()
    for wid in storage.list_workspaces():
        if settings.workspace_id and wid != settings.workspace_id:
            continue
        if wid not in workspaces:
            workspaces[wid] = {}
        for pid in storage.list_projects(wid):
            try:
                workspaces[wid][pid] = storage.load(wid, pid)
            except FileNotFoundError:
                continue
    if settings.workspace_id:
        workspaces = {k: v for k, v in workspaces.items() if k == settings.workspace_id}
    # Persist fixtures that aren't yet in storage
    for wid, projects in workspaces.items():
        for pid, project in projects.items():
            try:
                storage.load(wid, pid)
            except FileNotFoundError:
                _persist(wid, pid, project)


# === Workspace endpoints ===

@app.get("/workspaces", response_model=list[Workspace])
def list_workspaces():
    return [
        Workspace(id=wid, name=wid, project_ids=list(projects))
        for wid, projects in workspaces.items()
    ]


@app.get("/workspaces/{workspace_id}", response_model=Workspace)
def get_workspace(workspace_id: str):
    projects = workspaces.get(workspace_id)
    if projects is None:
        raise HTTPException(status_code=404, detail=f"Workspace '{workspace_id}' not found")
    return Workspace(id=workspace_id, name=workspace_id, project_ids=list(projects))


# === Project endpoints ===

@app.get("/workspaces/{workspace_id}/projects")
def list_projects(workspace_id: str):
    projects = workspaces.get(workspace_id)
    if projects is None:
        raise HTTPException(status_code=404, detail=f"Workspace '{workspace_id}' not found")
    return [p for p in projects.values()]


@app.get("/workspaces/{workspace_id}/projects/{project_id}")
def get_project(workspace_id: str, project_id: str):
    return _resolve(workspace_id, project_id)


@app.get("/workspaces/{workspace_id}/projects/{project_id}/lists/{list_name}")
def get_list(workspace_id: str, project_id: str, list_name: str):
    project = _resolve(workspace_id, project_id)
    data = getattr(project.lists, list_name, None)
    if data is None:
        raise HTTPException(status_code=404, detail=f"List '{list_name}' not found")
    return data


# === Card endpoints ===

@app.get("/workspaces/{workspace_id}/projects/{project_id}/cards/{card_id}")
def get_card(workspace_id: str, project_id: str, card_id: str):
    project = _resolve(workspace_id, project_id)
    card = _find_card(project, card_id)
    if card is None:
        raise HTTPException(status_code=404, detail=f"Card '{card_id}' not found")
    return card


@app.post("/workspaces/{workspace_id}/projects/{project_id}/cards", status_code=201, dependencies=[Depends(verify_token)])
def create_card(workspace_id: str, project_id: str, list_name: str, payload: Card):
    project = _resolve(workspace_id, project_id)
    items = getattr(project.lists, list_name, None)
    if items is None:
        raise HTTPException(status_code=404, detail=f"List '{list_name}' not found")
    items.append(payload)
    _persist(workspace_id, project_id, project)
    return payload


@app.put("/workspaces/{workspace_id}/projects/{project_id}/cards/{card_id}", dependencies=[Depends(verify_token)])
def update_card(workspace_id: str, project_id: str, card_id: str, payload: CardPatch):
    project = _resolve(workspace_id, project_id)
    card = _find_card(project, card_id)
    if card is None:
        raise HTTPException(status_code=404, detail=f"Card '{card_id}' not found")
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(card, field, value)
    _persist(workspace_id, project_id, project)
    return card


@app.delete("/workspaces/{workspace_id}/projects/{project_id}/cards/{card_id}", dependencies=[Depends(verify_token)])
def delete_card(workspace_id: str, project_id: str, card_id: str):
    project = _resolve(workspace_id, project_id)
    for list_name in ("observe", "orient", "decide", "act"):
        items = getattr(project.lists, list_name)
        for i, card in enumerate(items):
            if card.id == card_id:
                items.pop(i)
                _persist(workspace_id, project_id, project)
                return {"deleted": card_id}
    raise HTTPException(status_code=404, detail=f"Card '{card_id}' not found")

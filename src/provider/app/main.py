from pathlib import Path

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware

from app.auth import verify_token
from app.config import settings
from app.models import Card, CardPatch, Project
from app.storage import LocalStorage, S3Storage

app = FastAPI(title="QtConsult Provider", version="0.0.1")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

PROJECT_ID = "project1"
FIXTURE_PATH = Path(__file__).resolve().parents[3] / "assets" / "fixtures" / "projects" / f"{PROJECT_ID}.json"

if settings.storage_backend == "s3":
    storage = S3Storage(bucket=settings.s3_bucket, prefix=settings.s3_prefix)
else:
    storage = LocalStorage(data_dir=settings.data_dir)

project: Project | None = None


def _find_card(card_id: str) -> Card | None:
    for list_name in ("observe", "orient", "decide", "act"):
        for card in getattr(project.lists, list_name):
            if card.id == card_id:
                return card
    return None


def _find_list(card_id: str) -> list[Card] | None:
    for list_name in ("observe", "orient", "decide", "act"):
        items = getattr(project.lists, list_name)
        if any(c.id == card_id for c in items):
            return items
    return None


def _persist():
    storage.save(PROJECT_ID, project)


@app.on_event("startup")
def load_data():
    global project
    try:
        project = storage.load(PROJECT_ID)
    except FileNotFoundError:
        raw = FIXTURE_PATH.read_text("utf-8")
        project = Project.model_validate_json(raw)
        _persist()


@app.get("/project")
def get_project() -> Project:
    return project


@app.get("/project/lists/{list_name}")
def get_list(list_name: str):
    data = getattr(project.lists, list_name, None)
    if data is None:
        raise HTTPException(status_code=404, detail=f"List '{list_name}' not found")
    return data


@app.post("/project/cards", status_code=201, dependencies=[Depends(verify_token)])
def create_card(payload: Card, list_name: str):
    items = getattr(project.lists, list_name, None)
    if items is None:
        raise HTTPException(status_code=404, detail=f"List '{list_name}' not found")
    items.append(payload)
    _persist()
    return payload


@app.put("/project/cards/{card_id}", dependencies=[Depends(verify_token)])
def update_card(card_id: str, payload: CardPatch):
    card = _find_card(card_id)
    if card is None:
        raise HTTPException(status_code=404, detail=f"Card '{card_id}' not found")
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(card, field, value)
    _persist()
    return card


@app.delete("/project/cards/{card_id}", dependencies=[Depends(verify_token)])
def delete_card(card_id: str):
    for list_name in ("observe", "orient", "decide", "act"):
        items = getattr(project.lists, list_name)
        for i, card in enumerate(items):
            if card.id == card_id:
                items.pop(i)
                _persist()
                return {"deleted": card_id}
    raise HTTPException(status_code=404, detail=f"Card '{card_id}' not found")


@app.get("/project/cards/{card_id}")
def get_card(card_id: str):
    card = _find_card(card_id)
    if card is None:
        raise HTTPException(status_code=404, detail=f"Card '{card_id}' not found")
    return card

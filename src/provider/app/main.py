from pathlib import Path

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware

from app.auth import verify_token
from app.models import Card, Project

app = FastAPI(title="QtConsult Provider", version="0.0.1")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

DATA_PATH = Path(__file__).resolve().parents[3] / "assets" / "fixtures" / "projects" / "project1.json"

project: Project | None = None


def _find_card(card_id: str) -> Card | None:
    for list_name in ("observe", "orient", "decide", "act"):
        items = getattr(project.lists, list_name)
        for card in items:
            if card.id == card_id:
                return card
    return None


def _find_list(card_id: str) -> list[Card] | None:
    for list_name in ("observe", "orient", "decide", "act"):
        items = getattr(project.lists, list_name)
        for card in items:
            if card.id == card_id:
                return items
    return None


@app.on_event("startup")
def load_data():
    global project
    raw = DATA_PATH.read_text("utf-8")
    project = Project.model_validate_json(raw)


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
    return payload


@app.put("/project/cards/{card_id}", dependencies=[Depends(verify_token)])
def update_card(card_id: str, payload: Card):
    card = _find_card(card_id)
    if card is None:
        raise HTTPException(status_code=404, detail=f"Card '{card_id}' not found")
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(card, field, value)
    return card


@app.delete("/project/cards/{card_id}", dependencies=[Depends(verify_token)])
def delete_card(card_id: str):
    items = _find_list(card_id)
    if items is None:
        raise HTTPException(status_code=404, detail=f"Card '{card_id}' not found")
    for i, card in enumerate(items):
        if card.id == card_id:
            items.pop(i)
            return {"deleted": card_id}


@app.get("/project/cards/{card_id}")
def get_card(card_id: str):
    card = _find_card(card_id)
    if card is None:
        raise HTTPException(status_code=404, detail=f"Card '{card_id}' not found")
    return card

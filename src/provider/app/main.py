from pathlib import Path

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware

from app.auth import verify_token
from app.models import Card, CardInList, Project

app = FastAPI(title="QtConsult Provider", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

DATA_PATH = Path(__file__).resolve().parents[3] / "assets" / "fixtures" / "project.json"

project: Project | None = None


def _find_card(card_id: str) -> tuple[Card, str, str | None] | None:
    for list_name in ("observe", "orient", "decide", "act"):
        items = getattr(project.lists, list_name)
        if list_name == "observe":
            for sublist in items:
                for i, card in enumerate(sublist.cards):
                    if card.id == card_id:
                        return card, list_name, sublist.name
        else:
            for i, card in enumerate(items):
                if card.id == card_id:
                    return card, list_name, None
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
def create_card(payload: Card, list_name: str, sublist_name: str | None = None):
    items = getattr(project.lists, list_name, None)
    if items is None:
        raise HTTPException(status_code=404, detail=f"List '{list_name}' not found")
    if isinstance(items[0], CardInList):
        if not sublist_name:
            raise HTTPException(status_code=400, detail="sublist_name required for observe list")
        for sub in items:
            if sub.name == sublist_name:
                sub.cards.append(payload)
                return payload
        raise HTTPException(status_code=404, detail=f"Sublist '{sublist_name}' not found")
    items.append(payload)
    return payload


@app.put("/project/cards/{card_id}", dependencies=[Depends(verify_token)])
def update_card(card_id: str, payload: Card):
    result = _find_card(card_id)
    if result is None:
        raise HTTPException(status_code=404, detail=f"Card '{card_id}' not found")
    card, *_ = result
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(card, field, value)
    return card


@app.delete("/project/cards/{card_id}", dependencies=[Depends(verify_token)])
def delete_card(card_id: str):
    for list_name in ("observe", "orient", "decide", "act"):
        items = getattr(project.lists, list_name)
        if list_name == "observe":
            for sublist in items:
                for i, card in enumerate(sublist.cards):
                    if card.id == card_id:
                        sublist.cards.pop(i)
                        return {"deleted": card_id}
        else:
            for i, card in enumerate(items):
                if card.id == card_id:
                    items.pop(i)
                    return {"deleted": card_id}
    raise HTTPException(status_code=404, detail=f"Card '{card_id}' not found")


@app.get("/project/cards/{card_id}")
def get_card(card_id: str):
    result = _find_card(card_id)
    if result is None:
        raise HTTPException(status_code=404, detail=f"Card '{card_id}' not found")
    return result[0]

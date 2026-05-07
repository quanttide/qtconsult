from datetime import date
from pydantic import BaseModel, Field


class CardDate(BaseModel):
    start: date | None = None
    end: date | None = None


class Card(BaseModel):
    id: str
    title: str
    description: str = ""
    category: str | None = None
    types: list[str] = Field(default_factory=list)
    tags: list[str] = Field(default_factory=list)
    date: date | CardDate | None = None
    assignee: str | None = None
    upstream: list[str] = Field(default_factory=list)


class CardInList(BaseModel):
    name: str
    cards: list[Card]


class ProjectLists(BaseModel):
    observe: list[CardInList]
    orient: list[Card]
    decide: list[Card]
    act: list[Card]


class Project(BaseModel):
    name: str
    lists: ProjectLists

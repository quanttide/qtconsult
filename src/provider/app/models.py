from pydantic import BaseModel, ConfigDict, Field


class CardDate(BaseModel):
    start: str | None = None
    end: str | None = None


class Card(BaseModel):
    model_config = ConfigDict(extra='allow')

    id: str
    title: str
    description: str = ""
    category: str | None = None
    types: str | None = None
    tags: list[str] = Field(default_factory=list)
    date: str | CardDate | None = None
    assignee: str | None = None
    upstream: list[str] = Field(default_factory=list)


class CardPatch(BaseModel):
    model_config = ConfigDict(extra='allow')

    title: str | None = None
    description: str | None = None
    category: str | None = None
    types: str | None = None
    tags: list[str] | None = None
    date: str | CardDate | None = None
    assignee: str | None = None
    upstream: list[str] | None = None


class ProjectLists(BaseModel):
    observe: list[Card]
    orient: list[Card]
    decide: list[Card]
    act: list[Card]


class Project(BaseModel):
    name: str
    title: str
    workspace_id: str = ""
    lists: ProjectLists


class Workspace(BaseModel):
    id: str
    name: str
    project_ids: list[str]

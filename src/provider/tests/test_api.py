import pytest
from fastapi.testclient import TestClient
from pathlib import Path

from app.main import app, project
from app.models import Project
from app.storage import S3Storage

FIXTURE = Path(__file__).resolve().parents[3] / "assets" / "fixtures" / "projects" / "project1.json"


@pytest.fixture(autouse=True)
def reset_data():
    app.dependency_overrides.clear()
    raw = FIXTURE.read_text("utf-8")
    import app.main as m
    m.project = Project.model_validate_json(raw)
    yield


client = TestClient(app)


class TestGetProject:
    def test_returns_all_four_lists(self):
        resp = client.get("/project")
        assert resp.status_code == 200
        data = resp.json()
        assert set(data["lists"]) == {"observe", "orient", "decide", "act"}

    def test_each_list_contains_cards(self):
        resp = client.get("/project")
        data = resp.json()
        for name in ("observe", "orient", "decide", "act"):
            assert len(data["lists"][name]) > 0, f"{name} is empty"


class TestGetList:
    def test_returns_cards_by_list_name(self):
        resp = client.get("/project/lists/orient")
        assert resp.status_code == 200
        cards = resp.json()
        assert all("id" in c and "title" in c for c in cards)

    def test_unknown_list_returns_404(self):
        assert client.get("/project/lists/nonexistent").status_code == 404


class TestGetCard:
    def test_returns_card_by_id(self):
        resp = client.get("/project/cards/o1")
        assert resp.status_code == 200
        assert resp.json()["id"] == "o1"

    def test_unknown_card_returns_404(self):
        assert client.get("/project/cards/invalid").status_code == 404

    def test_observe_card_has_category(self):
        resp = client.get("/project/cards/o1")
        assert resp.json()["category"] in ("ideal", "reality")

    def test_orient_card_has_types(self):
        resp = client.get("/project/cards/i1")
        assert resp.json()["types"] is not None

    def test_decide_card_has_custom_fields(self):
        resp = client.get("/project/cards/s1")
        assert resp.json()["isSelected"] is True

    def test_act_card_has_status(self):
        resp = client.get("/project/cards/t1")
        assert resp.json()["status"] is not None


class TestCreateCard:
    CARD = {"id": "new-1", "title": "E2E 新建卡片", "description": "测试"}

    def test_create_in_orient(self):
        resp = client.post("/project/cards?list_name=orient", json=self.CARD)
        assert resp.status_code == 201
        assert client.get("/project/cards/new-1").status_code == 200

    def test_create_in_observe(self):
        resp = client.post("/project/cards?list_name=observe", json={**self.CARD, "id": "new-2"})
        assert resp.status_code == 201

    def test_missing_list_returns_404(self):
        resp = client.post("/project/cards?list_name=invalid", json=self.CARD)
        assert resp.status_code == 404


class TestUpdateCard:
    def test_update_title(self):
        resp = client.put("/project/cards/o1", json={"title": "更新后的标题"})
        assert resp.status_code == 200
        assert resp.json()["title"] == "更新后的标题"

    def test_partial_update_preserves_other_fields(self):
        client.put("/project/cards/t1", json={"status": "done", "progress": 1.0})
        resp = client.get("/project/cards/t1")
        assert resp.json()["assignee"] == "架构组"

    def test_unknown_card_returns_404(self):
        assert client.put("/project/cards/invalid", json={"title": "x"}).status_code == 404


class TestDeleteCard:
    def test_delete_removes_card(self):
        resp = client.delete("/project/cards/o4")
        assert resp.status_code == 200
        assert resp.json()["deleted"] == "o4"
        assert client.get("/project/cards/o4").status_code == 404

    def test_delete_unknown_card_returns_404(self):
        assert client.delete("/project/cards/invalid").status_code == 404


class TestAuth:
    def test_write_without_token_returns_401(self):
        from app.config import settings
        settings.api_token = "secret"
        try:
            resp = client.post("/project/cards?list_name=orient", json={"id": "x", "title": "x"})
            assert resp.status_code == 401
        finally:
            settings.api_token = ""

    def test_write_with_wrong_token_returns_401(self):
        from app.config import settings
        settings.api_token = "secret"
        try:
            resp = client.post(
                "/project/cards?list_name=orient",
                json={"id": "x", "title": "x"},
                headers={"Authorization": "Bearer wrong"},
            )
            assert resp.status_code == 401
        finally:
            settings.api_token = ""

    def test_write_with_correct_token_succeeds(self):
        from app.config import settings
        settings.api_token = "secret"
        try:
            resp = client.post(
                "/project/cards?list_name=orient",
                json={"id": "x", "title": "x"},
                headers={"Authorization": "Bearer secret"},
            )
            assert resp.status_code == 201
        finally:
            settings.api_token = ""


class TestValidation:
    def test_create_without_title_returns_422(self):
        resp = client.post("/project/cards?list_name=orient", json={"id": "x"})
        assert resp.status_code == 422

    def test_create_without_id_returns_422(self):
        resp = client.post("/project/cards?list_name=orient", json={"title": "x"})
        assert resp.status_code == 422


class FakeBody:
    def __init__(self, raw: bytes):
        self.raw = raw

    def read(self):
        return self.raw


class FakeS3Client:
    def __init__(self):
        self.objects = {}

    def get_object(self, Bucket, Key):
        if (Bucket, Key) not in self.objects:
            error = Exception("not found")
            error.response = {"Error": {"Code": "NoSuchKey", "Message": "not found"}}
            raise error
        return {"Body": FakeBody(self.objects[(Bucket, Key)])}

    def put_object(self, Bucket, Key, Body, ContentType):
        self.objects[(Bucket, Key)] = Body
        return {"ETag": "fake"}


class TestS3Storage:
    def test_key_uses_platform_prefix(self):
        storage = S3Storage(bucket="qtconsult-provider", prefix="platform", client=FakeS3Client())
        assert storage._key("project1") == "platform/project1.json"

    def test_save_and_load_project(self):
        raw = FIXTURE.read_text("utf-8")
        project = Project.model_validate_json(raw)
        storage = S3Storage(bucket="qtconsult-provider", prefix="platform", client=FakeS3Client())

        storage.save("project1", project)
        loaded = storage.load("project1")

        assert loaded.title == project.title
        assert len(loaded.lists.observe) == len(project.lists.observe)

    def test_missing_key_maps_to_file_not_found(self):
        storage = S3Storage(bucket="qtconsult-provider", prefix="platform", client=FakeS3Client())
        with pytest.raises(FileNotFoundError):
            storage.load("missing")

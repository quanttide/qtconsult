import pytest
from fastapi.testclient import TestClient
from pathlib import Path

from app.main import app
from app.models import Project
from app.storage import S3Storage

WID = "workspace1"
PID = "project1"
FIXTURE = Path(__file__).resolve().parents[3] / "assets" / "fixtures" / WID / f"{PID}.json"
BASE = f"/workspaces/{WID}/projects/{PID}"


@pytest.fixture(autouse=True)
def reset_data():
    app.dependency_overrides.clear()
    raw = FIXTURE.read_text("utf-8")
    import app.main as m
    m.workspaces = {WID: {PID: Project.model_validate_json(raw)}}
    yield


client = TestClient(app)


class TestWorkspaces:
    def test_list_workspaces(self):
        resp = client.get("/workspaces")
        assert resp.status_code == 200
        data = resp.json()
        assert any(ws["id"] == WID for ws in data)

    def test_get_workspace(self):
        resp = client.get(f"/workspaces/{WID}")
        assert resp.status_code == 200
        assert resp.json()["id"] == WID

    def test_unknown_workspace_returns_404(self):
        assert client.get("/workspaces/nonexistent").status_code == 404


class TestGetProject:
    def test_returns_all_four_lists(self):
        resp = client.get(f"{BASE}")
        assert resp.status_code == 200
        data = resp.json()
        assert set(data["lists"]) == {"observe", "orient", "decide", "act"}

    def test_each_list_contains_cards(self):
        resp = client.get(f"{BASE}")
        data = resp.json()
        for name in ("observe", "orient", "decide", "act"):
            assert len(data["lists"][name]) > 0, f"{name} is empty"

    def test_unknown_project_returns_404(self):
        assert client.get(f"/workspaces/{WID}/projects/nonexistent").status_code == 404

    def test_list_projects(self):
        resp = client.get(f"/workspaces/{WID}/projects")
        assert resp.status_code == 200
        assert any(p["name"] == PID for p in resp.json())


class TestGetList:
    def test_returns_cards_by_list_name(self):
        resp = client.get(f"{BASE}/lists/orient")
        assert resp.status_code == 200
        cards = resp.json()
        assert all("id" in c and "title" in c for c in cards)

    def test_unknown_list_returns_404(self):
        assert client.get(f"{BASE}/lists/nonexistent").status_code == 404


class TestGetCard:
    def test_returns_card_by_id(self):
        resp = client.get(f"{BASE}/cards/o1")
        assert resp.status_code == 200
        assert resp.json()["id"] == "o1"

    def test_unknown_card_returns_404(self):
        assert client.get(f"{BASE}/cards/invalid").status_code == 404

    def test_observe_card_has_category(self):
        resp = client.get(f"{BASE}/cards/o1")
        assert resp.json()["category"] in ("ideal", "reality")

    def test_orient_card_has_types(self):
        resp = client.get(f"{BASE}/cards/i1")
        assert resp.json()["types"] is not None

    def test_decide_card_has_custom_fields(self):
        resp = client.get(f"{BASE}/cards/s1")
        assert resp.json()["isSelected"] is True

    def test_act_card_has_status(self):
        resp = client.get(f"{BASE}/cards/t1")
        assert resp.json()["status"] is not None


class TestCreateCard:
    CARD = {"id": "new-1", "title": "E2E 新建卡片", "description": "测试"}

    def test_create_in_orient(self):
        resp = client.post(f"{BASE}/cards?list_name=orient", json=self.CARD)
        assert resp.status_code == 201
        assert client.get(f"{BASE}/cards/new-1").status_code == 200

    def test_create_in_observe(self):
        resp = client.post(f"{BASE}/cards?list_name=observe", json={**self.CARD, "id": "new-2"})
        assert resp.status_code == 201

    def test_missing_list_returns_404(self):
        resp = client.post(f"{BASE}/cards?list_name=invalid", json=self.CARD)
        assert resp.status_code == 404


class TestUpdateCard:
    def test_update_title(self):
        resp = client.put(f"{BASE}/cards/o1", json={"title": "更新后的标题"})
        assert resp.status_code == 200
        assert resp.json()["title"] == "更新后的标题"

    def test_partial_update_preserves_other_fields(self):
        client.put(f"{BASE}/cards/t1", json={"status": "done", "progress": 1.0})
        resp = client.get(f"{BASE}/cards/t1")
        assert resp.json()["assignee"] == "架构组"

    def test_unknown_card_returns_404(self):
        assert client.put(f"{BASE}/cards/invalid", json={"title": "x"}).status_code == 404


class TestDeleteCard:
    def test_delete_removes_card(self):
        resp = client.delete(f"{BASE}/cards/o4")
        assert resp.status_code == 200
        assert resp.json()["deleted"] == "o4"
        assert client.get(f"{BASE}/cards/o4").status_code == 404

    def test_delete_unknown_card_returns_404(self):
        assert client.delete(f"{BASE}/cards/invalid").status_code == 404


class TestAuth:
    def test_write_without_token_returns_401(self):
        from app.config import settings
        settings.api_token = "secret"
        try:
            resp = client.post(f"{BASE}/cards?list_name=orient", json={"id": "x", "title": "x"})
            assert resp.status_code == 401
        finally:
            settings.api_token = ""

    def test_write_with_wrong_token_returns_401(self):
        from app.config import settings
        settings.api_token = "secret"
        try:
            resp = client.post(
                f"{BASE}/cards?list_name=orient",
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
                f"{BASE}/cards?list_name=orient",
                json={"id": "x", "title": "x"},
                headers={"Authorization": "Bearer secret"},
            )
            assert resp.status_code == 201
        finally:
            settings.api_token = ""

    def test_token_scoped_to_workspace_succeeds(self):
        from app.config import settings
        settings.api_token = "secret"
        try:
            resp = client.post(
                f"{BASE}/cards?list_name=orient",
                json={"id": "x2", "title": "x"},
                headers={"Authorization": "Bearer workspace1:secret"},
            )
            assert resp.status_code == 201
        finally:
            settings.api_token = ""

    def test_token_scoped_to_wrong_workspace_returns_403(self):
        from app.config import settings
        settings.api_token = "secret"
        try:
            resp = client.post(
                f"{BASE}/cards?list_name=orient",
                json={"id": "x3", "title": "x"},
                headers={"Authorization": "Bearer workspace0:secret"},
            )
            assert resp.status_code == 403
        finally:
            settings.api_token = ""


class TestValidation:
    def test_create_without_title_returns_422(self):
        resp = client.post(f"{BASE}/cards?list_name=orient", json={"id": "x"})
        assert resp.status_code == 422

    def test_create_without_id_returns_422(self):
        resp = client.post(f"{BASE}/cards?list_name=orient", json={"title": "x"})
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


class TestOldRoutes:
    def test_old_project_root_returns_404(self):
        assert client.get("/project").status_code == 404

    def test_old_project_list_returns_404(self):
        assert client.get("/project/lists/observe").status_code == 404

    def test_old_project_card_returns_404(self):
        assert client.get("/project/cards/o1").status_code == 404


class TestMultiWorkspace:
    def test_workspaces_are_isolated(self):
        import app.main as m
        raw2 = FIXTURE.read_text("utf-8")
        p2 = Project.model_validate_json(raw2)
        p2.name = "project0"
        m.workspaces["workspace0"] = {"project0": p2}

        # Read workspace1 data
        resp1 = client.get(f"/workspaces/workspace1/projects/project1")
        assert resp1.status_code == 200
        assert resp1.json()["name"] == "project1"

        # Read workspace0 data
        resp0 = client.get(f"/workspaces/workspace0/projects/project0")
        assert resp0.status_code == 200
        assert resp0.json()["name"] == "project0"

        # Write to workspace0 does not affect workspace1
        client.put("/workspaces/workspace0/projects/project0/cards/o1", json={"title": "ws0-only"})
        resp1_after = client.get("/workspaces/workspace1/projects/project1/cards/o1")
        assert resp1_after.json()["title"] != "ws0-only"

    def test_list_projects_unknown_workspace_returns_404(self):
        assert client.get("/workspaces/nonexistent/projects").status_code == 404


class TestLocalStorage:
    def test_list_workspaces_returns_dirs(self, tmp_path):
        from app.storage import LocalStorage
        (tmp_path / "ws1").mkdir()
        (tmp_path / "ws2").mkdir()
        (tmp_path / "ws1" / "p1.json").write_text('{"name":"p1","title":"t1","lists":{"observe":[],"orient":[],"decide":[],"act":[]}}')
        (tmp_path / "ws2" / "p2.json").write_text('{"name":"p2","title":"t2","lists":{"observe":[],"orient":[],"decide":[],"act":[]}}')

        storage = LocalStorage(data_dir=tmp_path)
        assert storage.list_workspaces() == ["ws1", "ws2"]
        assert storage.list_projects("ws1") == ["p1"]
        assert storage.list_projects("ws2") == ["p2"]
        assert storage.list_projects("empty") == []

    def test_ignores_dotfiles_and_non_json(self, tmp_path):
        from app.storage import LocalStorage
        (tmp_path / "ws1").mkdir()
        (tmp_path / ".hidden").mkdir()
        (tmp_path / "ws1" / "p1.json").write_text('{}')
        (tmp_path / "ws1" / ".DS_Store").write_text("")
        (tmp_path / "ws1" / "readme.md").write_text("")

        storage = LocalStorage(data_dir=tmp_path)
        assert storage.list_workspaces() == ["ws1"]
        assert storage.list_projects("ws1") == ["p1"]


class FakeBody:
    def test_key_uses_platform_prefix(self):
        storage = S3Storage(bucket="qtconsult-provider", prefix="platform", client=FakeS3Client())
        assert storage._key("workspace1", "project1") == "platform/workspace1/project1.json"

    def test_save_and_load_project(self):
        raw = FIXTURE.read_text("utf-8")
        project = Project.model_validate_json(raw)
        storage = S3Storage(bucket="qtconsult-provider", prefix="platform", client=FakeS3Client())

        storage.save("workspace1", "project1", project)
        loaded = storage.load("workspace1", "project1")

        assert loaded.title == project.title
        assert len(loaded.lists.observe) == len(project.lists.observe)

    def test_missing_key_maps_to_file_not_found(self):
        storage = S3Storage(bucket="qtconsult-provider", prefix="platform", client=FakeS3Client())
        with pytest.raises(FileNotFoundError):
            storage.load("workspace1", "missing")

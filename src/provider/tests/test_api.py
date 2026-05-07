import pytest
from fastapi.testclient import TestClient

from app.main import app, project
from app.models import Project


@pytest.fixture(autouse=True)
def reset_project():
    from pathlib import Path
    raw = (Path(__file__).resolve().parents[3] / "assets" / "fixtures" / "projects" / "project1.json").read_text("utf-8")
    app.dependency_overrides.clear()
    project_data = Project.model_validate_json(raw)
    import app.main as m
    m.project = project_data
    yield


client = TestClient(app)


class TestRead:
    def test_get_project(self):
        resp = client.get("/project")
        assert resp.status_code == 200
        data = resp.json()
        assert data["title"] == "商家赋能平台数字化转型"
        assert "observe" in data["lists"]
        assert "orient" in data["lists"]
        assert "decide" in data["lists"]
        assert "act" in data["lists"]

    def test_get_observe_list(self):
        resp = client.get("/project/lists/observe")
        assert resp.status_code == 200
        data = resp.json()
        assert len(data) == 8

    def test_get_orient_list(self):
        resp = client.get("/project/lists/orient")
        assert resp.status_code == 200
        data = resp.json()
        assert len(data) == 4

    def test_get_decide_list(self):
        resp = client.get("/project/lists/decide")
        assert resp.status_code == 200
        data = resp.json()
        assert len(data) == 2

    def test_get_act_list(self):
        resp = client.get("/project/lists/act")
        assert resp.status_code == 200
        data = resp.json()
        assert len(data) == 6

    def test_get_list_not_found(self):
        resp = client.get("/project/lists/invalid")
        assert resp.status_code == 404

    def test_get_card(self):
        resp = client.get("/project/cards/o1")
        assert resp.status_code == 200
        assert resp.json()["title"] == "战略转型 · 商家赋能"

    def test_get_card_from_orient(self):
        resp = client.get("/project/cards/i1")
        assert resp.status_code == 200
        assert resp.json()["types"] == "战略技术断层"

    def test_get_card_from_decide(self):
        resp = client.get("/project/cards/s1")
        assert resp.status_code == 200
        assert resp.json()["isSelected"] is True

    def test_get_card_from_act(self):
        resp = client.get("/project/cards/t1")
        assert resp.status_code == 200
        assert resp.json()["status"] == "doing"

    def test_get_card_not_found(self):
        resp = client.get("/project/cards/nonexistent")
        assert resp.status_code == 404


class TestCreate:
    def test_create_card(self):
        payload = {
            "id": "i5",
            "title": "新洞察",
            "description": "测试创建",
            "types": ["数据基建"],
        }
        resp = client.post("/project/cards?list_name=orient", json=payload)
        assert resp.status_code == 201

        resp = client.get("/project/cards/i5")
        assert resp.status_code == 200

    def test_create_card_invalid_list(self):
        payload = {"id": "x1", "title": "invalid"}
        resp = client.post("/project/cards?list_name=invalid", json=payload)
        assert resp.status_code == 404


class TestUpdate:
    def test_update_card_title(self):
        resp = client.put("/project/cards/o1", json={"title": "更新后的标题"})
        assert resp.status_code == 200
        assert resp.json()["title"] == "更新后的标题"

    def test_update_card_partial(self):
        resp = client.put("/project/cards/t1", json={"status": "done", "progress": 1.0})
        assert resp.status_code == 200
        data = resp.json()
        assert data["status"] == "done"
        assert data["progress"] == 1.0
        assert data["assignee"] == "架构组"

    def test_update_card_not_found(self):
        resp = client.put("/project/cards/nonexistent", json={"title": "x"})
        assert resp.status_code == 404


class TestDelete:
    def test_delete_card(self):
        resp = client.delete("/project/cards/o4")
        assert resp.status_code == 200
        assert resp.json()["deleted"] == "o4"

        resp = client.get("/project/cards/o4")
        assert resp.status_code == 404

    def test_delete_card_not_found(self):
        resp = client.delete("/project/cards/nonexistent")
        assert resp.status_code == 404

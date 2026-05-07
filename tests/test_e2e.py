"""
端到端测试示例：Provider API 完整链路验证。

运行前提：
  1. Provider 已在本地启动：uv run uvicorn app.main:app
  2. 安装依赖：pip install httpx pytest

运行方式：
  cd src/provider && uv run --dev pytest ../../tests/ -v
"""

import httpx

BASE = "http://localhost:8000"
client = httpx.Client()


def test_load_project():
    resp = client.get(f"{BASE}/project")
    assert resp.status_code == 200
    data = resp.json()
    assert data["title"] == "商家赋能平台数字化转型"
    assert len(data["lists"]["observe"]) == 8
    assert len(data["lists"]["orient"]) == 4
    assert len(data["lists"]["decide"]) == 2
    assert len(data["lists"]["act"]) == 6


def test_get_observe_card():
    resp = client.get(f"{BASE}/project/cards/o1")
    assert resp.status_code == 200
    card = resp.json()
    assert card["title"] == "战略转型 · 商家赋能"
    assert card["category"] == "ideal"


def test_get_orient_card():
    resp = client.get(f"{BASE}/project/cards/i1")
    assert resp.status_code == 200
    card = resp.json()
    assert card["types"] == "战略技术断层"
    assert "o1" in card["upstream"]


def test_create_then_read_card():
    card = {"id": "e2e-1", "title": "E2E 测试卡片", "description": "端到端测试"}
    resp = client.post(f"{BASE}/project/cards?list_name=orient", json=card)
    assert resp.status_code == 201

    resp = client.get(f"{BASE}/project/cards/e2e-1")
    assert resp.status_code == 200
    assert resp.json()["title"] == "E2E 测试卡片"


def test_update_card_partial():
    resp = client.put(f"{BASE}/project/cards/t1", json={"status": "done", "progress": 1.0})
    assert resp.status_code == 200
    data = resp.json()
    assert data["status"] == "done"
    assert data["progress"] == 1.0
    assert data["assignee"] == "架构组"


def test_delete_then_not_found():
    resp = client.delete(f"{BASE}/project/cards/o8")
    assert resp.status_code == 200

    resp = client.get(f"{BASE}/project/cards/o8")
    assert resp.status_code == 404


def test_delete_nonexistent_returns_404():
    resp = client.delete(f"{BASE}/project/cards/nonexistent")
    assert resp.status_code == 404

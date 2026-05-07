"""Provider API 端到端测试（依赖运行中的 provider）"""

import httpx

BASE = "http://localhost:8000"
client = httpx.Client()


def test_load_project():
    resp = client.get(f"{BASE}/project")
    assert resp.status_code == 200
    data = resp.json()
    assert data["title"] == "商家赋能平台数字化转型"
    assert len(data["lists"]["observe"]) == 7
    assert len(data["lists"]["orient"]) == 4
    assert len(data["lists"]["decide"]) == 2
    assert len(data["lists"]["act"]) == 6


def test_get_orient_list():
    resp = client.get(f"{BASE}/project/lists/orient")
    assert resp.status_code == 200
    data = resp.json()
    assert len(data) == 4


def test_get_card():
    resp = client.get(f"{BASE}/project/cards/o1")
    assert resp.status_code == 200
    data = resp.json()
    assert data["title"] == "战略转型 · 商家赋能"

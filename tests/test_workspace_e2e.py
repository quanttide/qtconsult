"""
Workspace 隔离 E2E 验证。

用法：
    # 自动化运行（启动 Provider + 执行验证）
    uv run pytest tests/test_workspace_e2e.py -v

    # 或手动指定已运行的 Provider 地址
    PROVIDER_URL=http://127.0.0.1:8543 uv run pytest tests/test_workspace_e2e.py -v
"""

import json
import os
import shutil
import signal
import subprocess
import tempfile
import time

import pytest
import httpx

# 测试用最小化 fixture 数据
E2E_FIXTURE_W0 = {
    "name": "e2e-w0",
    "title": "E2E 测试 workspace0",
    "workspace_id": "workspace0",
    "lists": {
        "observe": [{"id": "e2e-o1", "title": "W0 观察卡片", "category": "ideal"}],
        "orient": [],
        "decide": [],
        "act": []
    }
}

E2E_FIXTURE_W1 = {
    "name": "e2e-w1",
    "title": "E2E 测试 workspace1",
    "workspace_id": "workspace1",
    "lists": {
        "observe": [{"id": "e2e-o2", "title": "W1 观察卡片", "category": "reality"}],
        "orient": [],
        "decide": [],
        "act": []
    }
}


def _start_provider(data_dir: str, port: int = 8543, api_token: str = ""):
    """启动 Provider 子进程，返回 Popen 对象。"""
    env = os.environ.copy()
    env["QTCONSULT_STORAGE"] = "local"
    env["QTCONSULT_DATA_DIR"] = data_dir
    if api_token:
        env["QTCONSULT_API_TOKEN"] = api_token

    proc = subprocess.Popen(
        ["uv", "run", "uvicorn", "app.main:app",
         "--host", "127.0.0.1", "--port", str(port)],
        cwd=os.path.join(os.path.dirname(os.path.dirname(__file__)), "src", "provider"),
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    # 等待启动
    for _ in range(30):
        try:
            resp = httpx.get(f"http://127.0.0.1:{port}/workspaces")
            if resp.status_code == 200:
                return proc
        except Exception:
            pass
        time.sleep(0.2)
    proc.kill()
    stdout, _ = proc.communicate()
    raise RuntimeError(f"Provider 启动失败:\n{stdout.decode('utf-8', errors='replace')}")


def _stop_provider(proc):
    """停止 Provider 子进程。"""
    proc.send_signal(signal.SIGTERM)
    try:
        proc.wait(timeout=5)
    except subprocess.TimeoutExpired:
        proc.kill()


def _seed_fixtures(data_dir: str):
    """将测试 fixture 写入 data_dir/{wid}/{pid}.json。"""
    import pathlib
    fixtures = {
        "workspace0": {"e2e-w0": E2E_FIXTURE_W0},
        "workspace1": {"e2e-w1": E2E_FIXTURE_W1},
    }
    for wid, projects in fixtures.items():
        wdir = pathlib.Path(data_dir) / wid
        wdir.mkdir(parents=True, exist_ok=True)
        for pid, data in projects.items():
            (wdir / f"{pid}.json").write_text(
                json.dumps(data, indent=2, ensure_ascii=False),
                encoding="utf-8",
            )


class TestWorkspaceE2E:
    """Provider 启动 + HTTP 全链路验证。"""

    @pytest.fixture(scope="class")
    def provider(self):
        """启动 Provider 并返回 base_url。"""
        with tempfile.TemporaryDirectory() as tmpdir:
            _seed_fixtures(tmpdir)
            proc = _start_provider(tmpdir)
            yield f"http://127.0.0.1:8543"
            _stop_provider(proc)

    def test_workspace_list(self, provider):
        """测试列出所有 workspace。"""
        resp = httpx.get(f"{provider}/workspaces")
        assert resp.status_code == 200
        ids = [w["id"] for w in resp.json()]
        assert "workspace0" in ids
        assert "workspace1" in ids

    def test_project_read(self, provider):
        """分别读取两个项目，标题正确。"""
        resp0 = httpx.get(f"{provider}/workspaces/workspace0/projects/e2e-w0")
        assert resp0.status_code == 200
        assert resp0.json()["title"] == "E2E 测试 workspace0"

        resp1 = httpx.get(f"{provider}/workspaces/workspace1/projects/e2e-w1")
        assert resp1.status_code == 200
        assert resp1.json()["title"] == "E2E 测试 workspace1"

    def test_data_isolation(self, provider):
        """workspace0 创建卡片，workspace1 不可见。"""
        # 在 workspace0 创建卡片
        resp = httpx.post(
            f"{provider}/workspaces/workspace0/projects/e2e-w0/cards?list_name=observe",
            json={"id": "e2e-new", "title": "仅 W0 可见", "category": "ideal"},
        )
        assert resp.status_code == 201

        # workspace0 能读到
        resp0 = httpx.get(f"{provider}/workspaces/workspace0/projects/e2e-w0/cards/e2e-new")
        assert resp0.status_code == 200

        # workspace1 不可见
        resp1 = httpx.get(f"{provider}/workspaces/workspace1/projects/e2e-w1/cards/e2e-new")
        assert resp1.status_code == 404

    def test_old_routes_gone(self, provider):
        """旧路由 /project 等应返回 404。"""
        assert httpx.get(f"{provider}/project").status_code == 404
        assert httpx.get(f"{provider}/project/lists/observe").status_code == 404
        assert httpx.get(f"{provider}/project/cards/o1").status_code == 404


class TestTokenScope:
    """Token scope 认证验证。"""

    @pytest.fixture(scope="class")
    def provider_scoped(self):
        """启动带 scope token 的 Provider。"""
        with tempfile.TemporaryDirectory() as tmpdir:
            _seed_fixtures(tmpdir)
            proc = _start_provider(tmpdir, port=8544, api_token="secret")
            yield f"http://127.0.0.1:8544"
            _stop_provider(proc)

    def test_scoped_token_can_write_own(self, provider_scoped):
        """workspace1:secret token 可写 workspace1。"""
        resp = httpx.post(
            f"{provider_scoped}/workspaces/workspace1/projects/e2e-w1/cards?list_name=observe",
            json={"id": "scoped-ok", "title": "Scope OK", "category": "ideal"},
            headers={"Authorization": "Bearer workspace1:secret"},
        )
        assert resp.status_code == 201

    def test_scoped_token_cannot_write_other(self, provider_scoped):
        """workspace1:secret token 写 workspace0 返回 403。"""
        resp = httpx.post(
            f"{provider_scoped}/workspaces/workspace0/projects/e2e-w0/cards?list_name=observe",
            json={"id": "scoped-fail", "title": "Should Fail", "category": "ideal"},
            headers={"Authorization": "Bearer workspace1:secret"},
        )
        assert resp.status_code == 403

    def test_global_token_works_for_any(self, provider_scoped):
        """全局 token 可写任意 workspace。"""
        resp = httpx.post(
            f"{provider_scoped}/workspaces/workspace0/projects/e2e-w0/cards?list_name=observe",
            json={"id": "global-ok", "title": "Global OK", "category": "ideal"},
            headers={"Authorization": "Bearer secret"},
        )
        assert resp.status_code == 201

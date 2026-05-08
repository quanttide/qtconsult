import json
import os
import signal
import subprocess
import time
from pathlib import Path

import httpx
import pytest

FIXTURE_W0 = Path(__file__).resolve().parents[3] / "assets" / "fixtures" / "workspace0" / "project0.json"
FIXTURE_W1 = Path(__file__).resolve().parents[3] / "assets" / "fixtures" / "workspace1" / "project1.json"
SEED_DIR_W0 = Path(__file__).parent / "_seed" / "workspace0"
SEED_DIR_W1 = Path(__file__).parent / "_seed" / "workspace1"


def _is_integration():
    return os.environ.get("QTCONSULT_TEST_MODE", "unit") == "integration"


def _setup_unit_app(tmpdir=None, api_token=""):
    """Replace in-memory workspaces with controlled test data.
    
    In unit mode, the startup event loads fixtures from assets/fixtures/.
    To override with our test data, we set QTCONSULT_DATA_DIR to a temp dir
    with seed data, and the storage overlay will merge it in.
    """
    from app.config import settings
    from app.main import app, workspaces, storage
    from app.models import Project

    if tmpdir:
        # Storage will load from tmpdir; fixtures from assets/ are still loaded
        # We need the storage to have different project IDs to avoid collision
        pass

    # Direct approach: clear and set workspaces after startup
    # The startup event runs when TestClient is created.
    # We'll patch after that happens.
    pass


def _init_workspaces():
    """Load controlled test data into app.main.workspaces."""
    import json
    from app.main import workspaces
    from app.models import Project

    raw0 = FIXTURE_W0.read_text("utf-8")
    raw1 = FIXTURE_W1.read_text("utf-8")
    workspaces.clear()
    workspaces["workspace0"] = {"project0": Project.model_validate_json(raw0)}
    workspaces["workspace1"] = {"project1": Project.model_validate_json(raw1)}


def _start_provider(tmpdir, port, api_token=""):
    env = os.environ.copy()
    env["QTCONSULT_STORAGE"] = "local"
    env["QTCONSULT_DATA_DIR"] = str(tmpdir)
    if api_token:
        env["QTCONSULT_API_TOKEN"] = api_token
    cwd = Path(__file__).resolve().parent.parent
    proc = subprocess.Popen(
        ["uv", "run", "uvicorn", "app.main:app",
         "--host", "127.0.0.1", "--port", str(port)],
        cwd=str(cwd), env=env,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for _ in range(30):
        try:
            if httpx.get(f"http://127.0.0.1:{port}/workspaces").status_code == 200:
                return proc
        except Exception:
            pass
        time.sleep(0.2)
    proc.kill()
    raise RuntimeError(f"Provider 启动失败 (端口 {port})")


def _stop_provider(proc):
    proc.send_signal(signal.SIGTERM)
    try:
        proc.wait(timeout=5)
    except subprocess.TimeoutExpired:
        proc.kill()


def _seed(tmpdir):
    for wid, src in [("workspace0", FIXTURE_W0), ("workspace1", FIXTURE_W1)]:
        d = tmpdir / wid
        d.mkdir()
        (d / f"{src.stem}.json").write_text(src.read_text("utf-8"))


@pytest.fixture
def provider(tmp_path_factory):
    if _is_integration():
        tmp = tmp_path_factory.mktemp("int")
        _seed(tmp)
        proc = _start_provider(tmp, 8756)
        yield
        _stop_provider(proc)
    else:
        yield


@pytest.fixture
def client(provider):
    if _is_integration():
        yield httpx.Client(base_url="http://127.0.0.1:8756")
    else:
        from app.main import app
        from fastapi.testclient import TestClient
        with TestClient(app) as c:
            _init_workspaces()
            yield c


@pytest.fixture
def auth_provider(tmp_path_factory):
    if _is_integration():
        tmp = tmp_path_factory.mktemp("auth")
        _seed(tmp)
        proc = _start_provider(tmp, 8757, api_token="secret")
        yield
        _stop_provider(proc)
    else:
        from app.config import settings
        settings.api_token = "secret"
        yield
        settings.api_token = ""


@pytest.fixture
def auth_client(auth_provider):
    if _is_integration():
        yield httpx.Client(base_url="http://127.0.0.1:8757")
    else:
        from app.main import app
        from fastapi.testclient import TestClient
        with TestClient(app) as c:
            _init_workspaces()
            yield c

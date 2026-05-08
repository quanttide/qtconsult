class TestWorkspaceList:
    def test_list_returns_both(self, client):
        resp = client.get("/workspaces")
        assert resp.status_code == 200
        ids = [w["id"] for w in resp.json()]
        assert "workspace0" in ids
        assert "workspace1" in ids

    def test_invalid_workspace_returns_404(self, client):
        assert client.get("/workspaces/nonexistent").status_code == 404


class TestProjectRead:
    def test_workspace0_project(self, client):
        resp = client.get("/workspaces/workspace0/projects/project0")
        assert resp.status_code == 200
        assert resp.json()["title"] == "量潮科技自我诊断"

    def test_workspace1_project(self, client):
        resp = client.get("/workspaces/workspace1/projects/project1")
        assert resp.status_code == 200
        assert resp.json()["title"] == "商家赋能平台数字化转型"

    def test_invalid_project_returns_404(self, client):
        assert client.get("/workspaces/workspace0/projects/nonexistent").status_code == 404

    def test_list_projects_in_workspace(self, client):
        resp = client.get("/workspaces/workspace0/projects")
        assert resp.status_code == 200
        names = [p["name"] for p in resp.json()]
        assert "project0" in names


class TestOldRoutes:
    def test_old_project_root_returns_404(self, client):
        assert client.get("/project").status_code == 404

    def test_old_project_lists_returns_404(self, client):
        assert client.get("/project/lists/observe").status_code == 404

    def test_old_project_cards_returns_404(self, client):
        assert client.get("/project/cards/o1").status_code == 404

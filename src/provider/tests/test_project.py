class TestCardCRUD:
    def test_create_card_in_observe(self, auth_client):
        resp = auth_client.post(
            "/workspaces/workspace0/projects/project0/cards?list_name=observe",
            json={"id": "e2e-c1", "title": "新卡片", "category": "ideal"},
            headers={"Authorization": "Bearer secret"},
        )
        assert resp.status_code == 201

    def test_create_card_in_orient(self, auth_client):
        resp = auth_client.post(
            "/workspaces/workspace0/projects/project0/cards?list_name=orient",
            json={"id": "e2e-c2", "title": "新洞察", "types": "技术领域"},
            headers={"Authorization": "Bearer secret"},
        )
        assert resp.status_code == 201

    def test_create_in_invalid_list_returns_404(self, auth_client):
        resp = auth_client.post(
            "/workspaces/workspace0/projects/project0/cards?list_name=invalid",
            json={"id": "e2e-c3", "title": "x"},
            headers={"Authorization": "Bearer secret"},
        )
        assert resp.status_code == 404

    def test_update_card_title(self, auth_client):
        resp = auth_client.put(
            "/workspaces/workspace0/projects/project0/cards/o1",
            json={"title": "已更新"},
            headers={"Authorization": "Bearer secret"},
        )
        assert resp.status_code == 200
        assert resp.json()["title"] == "已更新"

    def test_update_preserves_other_fields(self, auth_client):
        auth_client.put(
            "/workspaces/workspace0/projects/project0/cards/o1",
            json={"title": "改标题"},
            headers={"Authorization": "Bearer secret"},
        )
        resp = auth_client.get("/workspaces/workspace0/projects/project0/cards/o1")
        assert resp.json()["category"] == "reality"
        assert resp.json()["title"] == "改标题"

    def test_update_invalid_card_returns_404(self, auth_client):
        resp = auth_client.put(
            "/workspaces/workspace0/projects/project0/cards/nonexistent",
            json={"title": "x"},
            headers={"Authorization": "Bearer secret"},
        )
        assert resp.status_code == 404

    def test_create_and_delete_card(self, auth_client):
        auth_client.post(
            "/workspaces/workspace0/projects/project0/cards?list_name=observe",
            json={"id": "e2e-d1", "title": "待删除"},
            headers={"Authorization": "Bearer secret"},
        )
        del_resp = auth_client.delete(
            "/workspaces/workspace0/projects/project0/cards/e2e-d1",
            headers={"Authorization": "Bearer secret"},
        )
        assert del_resp.status_code == 200
        assert del_resp.json()["deleted"] == "e2e-d1"
        assert auth_client.get(
            "/workspaces/workspace0/projects/project0/cards/e2e-d1",
        ).status_code == 404

    def test_delete_invalid_card_returns_404(self, auth_client):
        assert auth_client.delete(
            "/workspaces/workspace0/projects/project0/cards/nonexistent",
            headers={"Authorization": "Bearer secret"},
        ).status_code == 404


class TestDataIsolation:
    def test_create_in_w0_not_visible_in_w1(self, auth_client):
        auth_client.post(
            "/workspaces/workspace0/projects/project0/cards?list_name=observe",
            json={"id": "e2e-x1", "title": "仅 W0"},
            headers={"Authorization": "Bearer secret"},
        )
        assert auth_client.get(
            "/workspaces/workspace0/projects/project0/cards/e2e-x1",
        ).status_code == 200
        assert auth_client.get(
            "/workspaces/workspace1/projects/project1/cards/e2e-x1",
        ).status_code == 404

    def test_w0_update_does_not_affect_w1(self, auth_client):
        auth_client.put(
            "/workspaces/workspace0/projects/project0/cards/o1",
            json={"title": "仅 W0 变更"},
            headers={"Authorization": "Bearer secret"},
        )
        w1 = auth_client.get("/workspaces/workspace1/projects/project1/cards/o1")
        assert w1.json()["title"] != "仅 W0 变更"

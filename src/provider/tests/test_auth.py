class TestAuthToken:
    def test_write_without_token_returns_401(self, auth_client):
        resp = auth_client.post(
            "/workspaces/workspace0/projects/project0/cards?list_name=observe",
            json={"id": "x", "title": "x"},
        )
        assert resp.status_code == 401

    def test_write_with_wrong_token_returns_401(self, auth_client):
        resp = auth_client.post(
            "/workspaces/workspace0/projects/project0/cards?list_name=observe",
            json={"id": "x", "title": "x"},
            headers={"Authorization": "Bearer wrong"},
        )
        assert resp.status_code == 401

    def test_write_with_correct_token_succeeds(self, auth_client):
        resp = auth_client.post(
            "/workspaces/workspace0/projects/project0/cards?list_name=observe",
            json={"id": "x", "title": "x"},
            headers={"Authorization": "Bearer secret"},
        )
        assert resp.status_code == 201


class TestTokenScope:
    def test_scoped_token_can_write_own_workspace(self, auth_client):
        resp = auth_client.post(
            "/workspaces/workspace1/projects/project1/cards?list_name=observe",
            json={"id": "s1", "title": "scope ok"},
            headers={"Authorization": "Bearer workspace1:secret"},
        )
        assert resp.status_code == 201

    def test_scoped_token_cannot_write_other_workspace(self, auth_client):
        resp = auth_client.post(
            "/workspaces/workspace0/projects/project0/cards?list_name=observe",
            json={"id": "s2", "title": "should fail"},
            headers={"Authorization": "Bearer workspace1:secret"},
        )
        assert resp.status_code == 403

    def test_scoped_token_can_read_own_workspace(self, auth_client):
        resp = auth_client.get(
            "/workspaces/workspace1/projects/project1",
            headers={"Authorization": "Bearer workspace1:secret"},
        )
        assert resp.status_code == 200


class TestValidation:
    def test_create_without_title_returns_422(self, auth_client):
        resp = auth_client.post(
            "/workspaces/workspace0/projects/project0/cards?list_name=observe",
            json={"id": "x"},
            headers={"Authorization": "Bearer secret"},
        )
        assert resp.status_code == 422

    def test_create_without_id_returns_422(self, auth_client):
        resp = auth_client.post(
            "/workspaces/workspace0/projects/project0/cards?list_name=observe",
            json={"title": "x"},
            headers={"Authorization": "Bearer secret"},
        )
        assert resp.status_code == 422

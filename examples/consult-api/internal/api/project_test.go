package api

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"

	"github.com/quanttide/qtconsult-provider-example/internal/store"
)

func testSetup(t *testing.T) (store.Store, func()) {
	t.Helper()
	dir, err := os.MkdirTemp("", "api-test-*")
	if err != nil {
		t.Fatalf("failed to create temp dir: %v", err)
	}
	s, err := store.New(store.Config{Driver: "file", Path: dir})
	if err != nil {
		os.RemoveAll(dir)
		t.Fatalf("failed to create store: %v", err)
	}
	return s, func() {
		s.Close()
		os.RemoveAll(dir)
	}
}

func registerConsultRoutes(h *ConsultHandler) *http.ServeMux {
	mux := http.NewServeMux()
	// qtconsult
	mux.HandleFunc("GET /api/v1/qtconsult/projects", h.ListProjects)
	mux.HandleFunc("POST /api/v1/qtconsult/projects", h.CreateProject)
	mux.HandleFunc("GET /api/v1/qtconsult/projects/{id}", h.GetProject)
	mux.HandleFunc("PUT /api/v1/qtconsult/projects/{id}", h.UpdateProject)
	mux.HandleFunc("DELETE /api/v1/qtconsult/projects/{id}", h.DeleteProject)
	return mux
}

func TestProjectCRUD(t *testing.T) {
	s, cleanup := testSetup(t)
	defer cleanup()

	h := NewConsultHandler(s)
	mux := registerConsultRoutes(h)
	base := "/api/v1/qtconsult/projects"

	t.Run("Create and Get", func(t *testing.T) {
		body := `{"name":"Project Alpha","client":"Client X","stage":"init","status":"active"}`
		req := httptest.NewRequest("POST", base, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusCreated {
			t.Fatalf("expected 201, got %d: %s", rec.Code, rec.Body.String())
		}

		var item map[string]any
		json.Unmarshal(rec.Body.Bytes(), &item)
		id := item["id"].(string)

		req = httptest.NewRequest("GET", base+"/"+id, nil)
		rec = httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusOK {
			t.Fatalf("expected 200, got %d", rec.Code)
		}
	})

	t.Run("List", func(t *testing.T) {
		req := httptest.NewRequest("GET", base, nil)
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusOK {
			t.Errorf("expected 200, got %d", rec.Code)
		}
	})

	t.Run("Update", func(t *testing.T) {
		body := `{"name":"Project Alpha","client":"Client X","stage":"init","status":"active"}`
		req := httptest.NewRequest("POST", base, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		var item map[string]any
		json.Unmarshal(rec.Body.Bytes(), &item)
		id := item["id"].(string)

		updateBody := `{"name":"Project Alpha Updated","client":"Client X","stage":"planning","status":"active"}`
		req = httptest.NewRequest("PUT", base+"/"+id, strings.NewReader(updateBody))
		req.Header.Set("Content-Type", "application/json")
		rec = httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusOK {
			t.Fatalf("expected 200, got %d: %s", rec.Code, rec.Body.String())
		}

		var updated map[string]any
		json.Unmarshal(rec.Body.Bytes(), &updated)
		if updated["name"] != "Project Alpha Updated" {
			t.Errorf("expected updated name, got %v", updated["name"])
		}
	})

	t.Run("Delete", func(t *testing.T) {
		body := `{"name":"Temp Project"}`
		req := httptest.NewRequest("POST", base, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		var item map[string]any
		json.Unmarshal(rec.Body.Bytes(), &item)
		id := item["id"].(string)

		req = httptest.NewRequest("DELETE", base+"/"+id, nil)
		rec = httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusNoContent {
			t.Errorf("expected 204, got %d", rec.Code)
		}
	})

	t.Run("missing name returns 400", func(t *testing.T) {
		req := httptest.NewRequest("POST", base, strings.NewReader(`{}`))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusBadRequest {
			t.Errorf("expected 400, got %d", rec.Code)
		}
	})
}

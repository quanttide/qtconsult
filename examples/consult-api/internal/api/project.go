package api

import (
	"encoding/json"
	"log/slog"
	"net/http"

	"github.com/quanttide/qtconsult-provider-example/internal/model"
	"github.com/quanttide/qtconsult-provider-example/internal/store"
)

type ConsultHandler struct {
	store store.Store
}

func NewConsultHandler(st store.Store) *ConsultHandler {
	return &ConsultHandler{store: st}
}

// --- QtConsult Projects ---

func (h *ConsultHandler) ListProjects(w http.ResponseWriter, r *http.Request) {
	data, err := h.store.List("qtconsult/projects")
	if err != nil {
		slog.Error("list projects", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to list projects", http.StatusInternalServerError)
		return
	}
	var items []model.QtConsultProject
	if err := json.Unmarshal(data, &items); err != nil {
		slog.Error("parse projects", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse projects", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, items, http.StatusOK)
}

func (h *ConsultHandler) CreateProject(w http.ResponseWriter, r *http.Request) {
	var item model.QtConsultProject
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	if item.Name == "" {
		WriteError(w, "VALIDATION_ERROR", "name is required", http.StatusBadRequest)
		return
	}

	data, err := json.Marshal(item)
	if err != nil {
		slog.Error("encode project", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}

	id, err := h.store.Create("qtconsult/projects", data)
	if err != nil {
		slog.Error("create project", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to create project", http.StatusInternalServerError)
		return
	}

	item.ID = id
	data, err = json.Marshal(item)
	if err != nil {
		slog.Error("encode project with id", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("qtconsult/projects", id, data); err != nil {
		slog.Error("persist project id", "error", err)
	}

	WriteJSON(w, item, http.StatusCreated)
}

func (h *ConsultHandler) GetProject(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	data, err := h.store.Get("qtconsult/projects", id)
	if err != nil {
		WriteError(w, "NOT_FOUND", "project not found", http.StatusNotFound)
		return
	}
	var item model.QtConsultProject
	if err := json.Unmarshal(data, &item); err != nil {
		slog.Error("parse project", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse project", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, item, http.StatusOK)
}

func (h *ConsultHandler) UpdateProject(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var item model.QtConsultProject
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	item.ID = id

	data, err := json.Marshal(item)
	if err != nil {
		slog.Error("encode project", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("qtconsult/projects", id, data); err != nil {
		WriteError(w, "NOT_FOUND", "project not found", http.StatusNotFound)
		return
	}
	WriteJSON(w, item, http.StatusOK)
}

func (h *ConsultHandler) DeleteProject(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if err := h.store.Delete("qtconsult/projects", id); err != nil {
		WriteError(w, "NOT_FOUND", "project not found", http.StatusNotFound)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

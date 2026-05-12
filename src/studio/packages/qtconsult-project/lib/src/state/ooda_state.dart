import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:data_sources/cache_service.dart';
import 'package:data_sources/provider_service.dart';
import 'package:qtconsult_project/qtconsult_project.dart';

class OodaState extends ChangeNotifier {
  final Project _project;
  final CacheService _cache;
  final ProviderService? _provider;
  final String _workspaceId;
  final String _projectId;
  final Set<String> _dirtyCardIds = {};
  bool _dirty = false;

  OodaState(this._project, this._cache, {ProviderService? provider, String workspaceId = '', String projectId = ''})
      : _workspaceId = workspaceId,
        _projectId = projectId,
        _provider = provider;

  Project get project => _project;

  bool get hasUnsavedChanges => _dirty;

  void toggleObserveConfirm(String id) {
    final index = _project.lists.observe.indexWhere((c) => c.id == id);
    if (index == -1) return;
    final card = _project.lists.observe[index];
    final wasConfirmed = card.custom['status'] == 'confirmed';
    _project.lists.observe[index] = BoardCard(
      id: card.id, title: card.title, description: card.description,
      category: card.category, tags: card.tags,
      date: card.date, assignee: card.assignee,
      custom: {
        ...card.custom,
        'upstream': card.upstream,
        'status': wasConfirmed ? 'pending' : 'confirmed',
      },
    );
    _markDirty(card.id);
  }

  void toggleStrategySelect(String id) {
    final index = _project.lists.decide.indexWhere((c) => c.id == id);
    if (index == -1) return;
    final card = _project.lists.decide[index];
    _project.lists.decide[index] = BoardCard(
      id: card.id, title: card.title, description: card.description,
      category: card.custom['isSelected'] == true ? null : 'selected',
      tags: card.tags, date: card.date,
      assignee: card.assignee,
      custom: {
        ...card.custom,
        'upstream': card.upstream,
        'isSelected': card.custom['isSelected'] != true,
      },
    );
    _markDirty(card.id);
  }

  void updateClientNote(String id, String note) {
    final index = _project.lists.decide.indexWhere((c) => c.id == id);
    if (index == -1) return;
    final card = _project.lists.decide[index];
    _project.lists.decide[index] = BoardCard(
      id: card.id, title: card.title, description: card.description,
      category: card.category, tags: card.tags,
      date: card.date, assignee: card.assignee,
      custom: {
        ...card.custom,
        'upstream': card.upstream,
        'clientNote': note,
      },
    );
    _markDirty(card.id);
  }

  void _markDirty(String cardId) {
    _dirty = true;
    _dirtyCardIds.add(cardId);
    notifyListeners();
    _flushInBackground();
  }

  Future<void> flush() async {
    if (!_dirty) return;
    if (_provider != null) {
      for (final cardId in _dirtyCardIds.toList()) {
        final card = _findCard(cardId);
        if (card == null) continue;
        await _provider!.updateCard(_workspaceId, _projectId, card.toJson());
      }
    }
    await _cache.save(jsonEncode(_project.toJson()));
    _dirty = false;
    _dirtyCardIds.clear();
  }

  void _flushInBackground() {
    flush().catchError((error) {
      debugPrint('OodaState flush failed: $error');
    });
  }

  BoardCard? _findCard(String cardId) {
    final lists = [
      _project.lists.observe,
      _project.lists.orient,
      _project.lists.decide,
      _project.lists.act,
    ];
    for (final list in lists) {
      for (final card in list) {
        if (card.id == cardId) return card;
      }
    }
    return null;
  }
}

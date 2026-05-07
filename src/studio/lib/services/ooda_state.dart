import 'package:flutter/foundation.dart';
import 'package:qtconsult_studio/models/ooda_data.dart';
import 'package:qtconsult_studio/services/cache_service.dart';

class OodaState extends ChangeNotifier {
  final Project _project;
  final CacheService _cache;
  bool _dirty = false;

  OodaState(this._project, this._cache);

  Project get project => _project;

  bool get hasUnsavedChanges => _dirty;

  void toggleObserveConfirm(String id) {
    final index = _project.lists.observe.indexWhere((c) => c.id == id);
    if (index == -1) return;
    final card = _project.lists.observe[index];
    final wasConfirmed = card.custom['status'] == 'confirmed';
    _project.lists.observe[index] = BoardCard(
      id: card.id, title: card.title, description: card.description,
      category: card.category, types: card.types, tags: card.tags,
      date: card.date, assignee: card.assignee, upstream: card.upstream,
      custom: {...card.custom, 'status': wasConfirmed ? 'pending' : 'confirmed'},
    );
    _markDirty();
  }

  void toggleStrategySelect(String id) {
    final index = _project.lists.decide.indexWhere((c) => c.id == id);
    if (index == -1) return;
    final card = _project.lists.decide[index];
    final updated = card.copyWith(
      category: card.custom['isSelected'] == true ? null : 'selected',
    );
    _project.lists.decide[index] = BoardCard(
      id: card.id, title: card.title, description: card.description,
      category: card.custom['isSelected'] == true ? null : 'selected',
      types: card.types, tags: card.tags, date: card.date,
      assignee: card.assignee, upstream: card.upstream,
      custom: {...card.custom, 'isSelected': card.custom['isSelected'] != true},
    );
    _markDirty();
  }

  void updateClientNote(String id, String note) {
    final index = _project.lists.decide.indexWhere((c) => c.id == id);
    if (index == -1) return;
    final card = _project.lists.decide[index];
    _project.lists.decide[index] = BoardCard(
      id: card.id, title: card.title, description: card.description,
      category: card.category, types: card.types, tags: card.tags,
      date: card.date, assignee: card.assignee, upstream: card.upstream,
      custom: {...card.custom, 'clientNote': note},
    );
    _markDirty();
  }

  void _markDirty() {
    _dirty = true;
    notifyListeners();
  }

  Future<void> flush() async {
    if (!_dirty) return;
    await _cache.save(_project);
    _dirty = false;
  }
}

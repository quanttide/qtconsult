import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:data_sources/cache_service.dart';
import 'package:data_sources/provider_service.dart';
import 'package:quanttide_project/quanttide_project.dart';
import '../project_lists.dart';

class ConsultState extends ChangeNotifier {
  List<Task> _tasks;
  final CacheService _cache;
  final ProviderService? _provider;
  final String _workspaceId;
  final String _projectId;
  final Set<String> _dirtyTaskIds = {};
  bool _dirty = false;

  ConsultState(this._tasks, this._cache,
      {ProviderService? provider, String workspaceId = '', String projectId = ''})
      : _workspaceId = workspaceId,
        _projectId = projectId,
        _provider = provider;

  ProjectLists get lists => ProjectLists(tasks: _tasks);

  bool get hasUnsavedChanges => _dirty;

  void toggleObserveConfirm(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final t = _tasks[index];
    _tasks[index] = Task(
      id: t.id, title: t.title, description: t.description,
      type: t.type, category: t.category, tags: t.tags,
      status: t.status == 'confirmed' ? 'pending' : 'confirmed',
      priority: t.priority,
      assigner: t.assigner, assignee: t.assignee,
      startAt: t.startAt, endAt: t.endAt,
      createdBy: t.createdBy, createdAt: t.createdAt,
      updatedBy: t.updatedBy, updatedAt: t.updatedAt,
    );
    _markDirty(id);
  }

  void toggleStrategySelect(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final t = _tasks[index];
    final tags = Map<String, String>.from(t.tags);
    if (tags['isSelected'] == 'true') {
      tags.remove('isSelected');
    } else {
      tags['isSelected'] = 'true';
    }
    _tasks[index] = Task(
      id: t.id, title: t.title, description: t.description,
      type: t.type, category: t.category, tags: tags,
      status: t.status, priority: t.priority,
      assigner: t.assigner, assignee: t.assignee,
      startAt: t.startAt, endAt: t.endAt,
      createdBy: t.createdBy, createdAt: t.createdAt,
      updatedBy: t.updatedBy, updatedAt: t.updatedAt,
    );
    _markDirty(id);
  }

  void updateClientNote(String id, String note) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final t = _tasks[index];
    final tags = Map<String, String>.from(t.tags);
    tags['clientNote'] = note;
    _tasks[index] = Task(
      id: t.id, title: t.title, description: t.description,
      type: t.type, category: t.category, tags: tags,
      status: t.status, priority: t.priority,
      assigner: t.assigner, assignee: t.assignee,
      startAt: t.startAt, endAt: t.endAt,
      createdBy: t.createdBy, createdAt: t.createdAt,
      updatedBy: t.updatedBy, updatedAt: t.updatedAt,
    );
    _markDirty(id);
  }

  void _markDirty(String taskId) {
    _dirty = true;
    _dirtyTaskIds.add(taskId);
    notifyListeners();
    _flushInBackground();
  }

  Future<void> flush() async {
    if (!_dirty) return;
    if (_provider != null) {
      for (final taskId in _dirtyTaskIds.toList()) {
        final index = _tasks.indexWhere((t) => t.id == taskId);
        if (index == -1) continue;
        await _provider!.updateCard(_workspaceId, _projectId, _tasks[index].toJson());
      }
    }
    await _cache.save(jsonEncode(_tasks.map((t) => t.toJson()).toList()));
    _dirty = false;
    _dirtyTaskIds.clear();
  }

  void _flushInBackground() {
    flush().catchError((error) {
      debugPrint('ConsultState flush failed: $error');
    });
  }
}

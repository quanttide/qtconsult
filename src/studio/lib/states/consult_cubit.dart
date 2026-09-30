import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:quanttide_project/quanttide_project.dart';

import '../services/cache_service.dart';
import '../services/provider_service.dart';
import 'consult_state.dart';

/// 咨询看板业务逻辑：卡片交互、脏任务跟踪与后台回写。
class ConsultCubit extends Cubit<ConsultState> {
  /// 创建看板逻辑：`cache` 与 `provider`（可选）负责持久化，`workspaceId`/`projectId` 定位回写目标。
  ConsultCubit(
    List<Task> tasks,
    CacheService cache, {
    ProviderService? provider,
    String workspaceId = '',
    String projectId = '',
  }) : _tasks = List.of(tasks),
       _cache = cache,
       _provider = provider,
       _workspaceId = workspaceId,
       _projectId = projectId,
       super(ConsultState(tasks: List<Task>.unmodifiable(tasks)));

  final List<Task> _tasks;
  final CacheService _cache;
  final ProviderService? _provider;
  final String _workspaceId;
  final String _projectId;
  final Set<String> _dirtyTaskIds = {};

  /// 切换卡片的澄清确认状态（`confirmed` ⇄ `pending`）。
  void toggleClarifyConfirm(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final t = _tasks[index];
    _tasks[index] = _copyWith(
      t,
      status: t.status == 'confirmed' ? 'pending' : 'confirmed',
    );
    _touch(id);
  }

  /// 切换卡片的方案中标记（`isSelected` 标签）。
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
    _tasks[index] = _copyWith(t, tags: tags);
    _touch(id);
  }

  /// 写入客户沟通备注（`clientNote` 标签）。
  void updateClientNote(String id, String note) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final t = _tasks[index];
    final tags = Map<String, String>.from(t.tags);
    tags['clientNote'] = note;
    _tasks[index] = _copyWith(t, tags: tags);
    _touch(id);
  }

  /// 将脏任务回写 provider 并同步本地缓存，完成后清理脏标记。
  Future<void> flush() async {
    if (!state.hasUnsavedChanges) return;
    final provider = _provider;
    if (provider != null) {
      for (final taskId in _dirtyTaskIds.toList()) {
        final index = _tasks.indexWhere((t) => t.id == taskId);
        if (index == -1) continue;
        await provider.updateCard(
          _workspaceId,
          _projectId,
          _tasks[index].toJson(),
        );
      }
    }
    await _cache.save(jsonEncode(_tasks.map((t) => t.toJson()).toList()));
    _dirtyTaskIds.clear();
    if (isClosed) return;
    emit(ConsultState(tasks: List<Task>.unmodifiable(_tasks)));
  }

  void _touch(String taskId) {
    _dirtyTaskIds.add(taskId);
    emit(
      ConsultState(
        tasks: List<Task>.unmodifiable(_tasks),
        hasUnsavedChanges: true,
      ),
    );
    _flushInBackground();
  }

  void _flushInBackground() {
    flush().catchError((Object error) {
      log('ConsultCubit flush failed: $error');
    });
  }

  Task _copyWith(Task t, {Map<String, String>? tags, String? status}) {
    return Task(
      id: t.id,
      title: t.title,
      description: t.description,
      type: t.type,
      category: t.category,
      tags: tags ?? t.tags,
      status: status ?? t.status,
      priority: t.priority,
      assigner: t.assigner,
      assignee: t.assignee,
      startAt: t.startAt,
      endAt: t.endAt,
      createdBy: t.createdBy,
      createdAt: t.createdAt,
      updatedBy: t.updatedBy,
      updatedAt: t.updatedAt,
    );
  }
}

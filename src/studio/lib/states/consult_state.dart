import 'package:quanttide_project/quanttide_project.dart';

import '../models/project_lists.dart';

/// 咨询看板状态：任务列表快照与待回写标记。
class ConsultState {
  /// 创建看板状态快照。
  const ConsultState({required this.tasks, this.hasUnsavedChanges = false});

  /// 当前全量任务列表（不可变快照）。
  final List<Task> tasks;

  /// 是否存在尚未回写成功的本地改动。
  final bool hasUnsavedChanges;

  /// 按阶段分组的只读视图。
  ProjectLists get lists => ProjectLists(tasks: tasks);
}

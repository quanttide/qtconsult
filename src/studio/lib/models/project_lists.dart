import 'package:quanttide_project/quanttide_project.dart';

/// 按领域聚类的一组调研任务。
class TaskCluster {
  /// 聚类名称，取自任务 `domain` 标签。
  final String name;

  /// 聚类内的任务列表。
  final List<Task> tasks;

  /// 创建任务聚类。
  const TaskCluster({required this.name, required this.tasks});
}

/// 看板任务集合，按阶段类型分组并提供聚类视图。
class ProjectLists {
  /// 全量任务列表。
  final List<Task> tasks;

  /// 由任务列表创建分组视图。
  const ProjectLists({required this.tasks});

  /// 需求澄清（clarify）阶段的任务。
  List<Task> get clarify => tasks.where((t) => t.type == 'clarify').toList();

  /// 调研分析（research）阶段的任务。
  List<Task> get research => tasks.where((t) => t.type == 'research').toList();

  /// 决策方案（decide）阶段的任务。
  List<Task> get decide => tasks.where((t) => t.type == 'decide').toList();

  /// 执行跟踪（execute）阶段的任务。
  List<Task> get execute => tasks.where((t) => t.type == 'execute').toList();

  /// 调研任务按 `domain` 标签聚类的结果，无标签者归入“未分类”。
  List<TaskCluster> get clusters {
    final map = <String, List<Task>>{};
    for (final task in research) {
      final key = task.tags['domain'] ?? '未分类';
      map.putIfAbsent(key, () => []).add(task);
    }
    return map.entries
        .map((e) => TaskCluster(name: e.key, tasks: e.value))
        .toList();
  }
}

/// 咨询任务的领域扩展。
extension TaskConsultExtension on Task {
  /// 上游关联来源，存储在 `upstream` 标签中，以逗号分隔。
  List<String> get upstream =>
      tags['upstream']?.split(',').where((s) => s.isNotEmpty).toList() ?? [];
}

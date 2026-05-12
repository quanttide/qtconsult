import 'package:quanttide_project/quanttide_project.dart';

class TaskCluster {
  final String name;
  final List<Task> tasks;
  const TaskCluster({required this.name, required this.tasks});
}

class ProjectLists {
  final List<Task> tasks;

  const ProjectLists({required this.tasks});

  List<Task> get observe => tasks.where((t) => t.type == 'clarify' || t.type == 'research').toList();
  List<Task> get orient => tasks.where((t) => t.type == 'orient').toList();
  List<Task> get decide => tasks.where((t) => t.type == 'decide').toList();
  List<Task> get act => tasks.where((t) => t.type == 'act').toList();

  List<Task> get ideals =>
      tasks.where((t) => t.type == 'clarify').toList();
  List<Task> get realities =>
      tasks.where((t) => t.type == 'research').toList();

  List<TaskCluster> get clusters {
    final map = <String, List<Task>>{};
    for (final task in orient) {
      final key = task.tags['domain'] ?? '未分类';
      map.putIfAbsent(key, () => []).add(task);
    }
    return map.entries
        .map((e) => TaskCluster(name: e.key, tasks: e.value))
        .toList();
  }
}

extension TaskOodaExtension on Task {
  List<String> get upstream =>
      (tags['upstream'] as String?)?.split(',').where((s) => s.isNotEmpty).toList() ?? [];
}

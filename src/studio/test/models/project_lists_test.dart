import 'package:flutter_test/flutter_test.dart';
import 'package:qtconsult_studio/qtconsult_studio.dart';

List<Task> makeTestTasks() {
  return [
    Task(
      id: 'o1',
      title: '调研卡片',
      description: '测试描述',
      type: 'clarify',
      tags: {'source': '访谈'},
      status: 'pending',
    ),
    Task(
      id: 'o2',
      title: '现实卡片',
      type: 'research',
      tags: {'domain': '技术领域', 'source': '审计'},
      status: 'confirmed',
    ),
    Task(
      id: 'i1',
      title: '洞察测试',
      type: 'research',
      tags: {'domain': '技术领域', 'rootCause': '根因', 'impact': '影响'},
    ),
    Task(
      id: 's1',
      title: '方案A',
      type: 'decide',
      tags: {'advantage': '优势', 'isSelected': 'true'},
    ),
    Task(
      id: 't1',
      title: '任务1',
      type: 'execute',
      assignee: '某人',
      status: 'doing',
      tags: {'progress': '0.5'},
    ),
  ];
}

void main() {
  group('ProjectLists', () {
    test('分析列按聚类分组', () {
      final lists = ProjectLists(tasks: makeTestTasks());
      final clusters = lists.clusters;
      expect(clusters.length, 1);
      expect(clusters[0].name, '技术领域');
      expect(clusters[0].tasks.length, 2);
    });

    test('按 type 分组', () {
      final lists = ProjectLists(tasks: makeTestTasks());
      expect(lists.clarify.length, 1);
      expect(lists.research.length, 2);
      expect(lists.clarify[0].id, 'o1');
      expect(lists.research[0].id, 'o2');
    });
  });
}

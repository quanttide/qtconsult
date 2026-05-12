import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtconsult_project/qtconsult_project.dart';

List<Task> makeTestTasks() {
  return [
    Task(id: 'o1', title: '调研卡片', description: '测试描述', type: 'observe-ideal',
        tags: {'source': '访谈'}, status: 'pending'),
    Task(id: 'o2', title: '现实卡片', type: 'observe-reality',
        tags: {'source': '审计'}, status: 'confirmed'),
    Task(id: 'i1', title: '洞察测试', type: 'orient',
        tags: {'domain': '技术领域', 'rootCause': '根因', 'impact': '影响'}),
    Task(id: 's1', title: '方案A', type: 'decide',
        tags: {'advantage': '优势', 'isSelected': 'true'}),
    Task(id: 't1', title: '任务1', type: 'act', assignee: '某人', status: 'doing',
        tags: {'progress': '0.5'}),
  ];
}

void main() {
  group('ProjectLists', () {
    test('分析列按聚类分组', () {
      final lists = ProjectLists(tasks: makeTestTasks());
      final clusters = lists.clusters;
      expect(clusters.length, 1);
      expect(clusters[0].name, '技术领域');
      expect(clusters[0].tasks.length, 1);
    });

    test('Observe 按 type 子类型分组', () {
      final lists = ProjectLists(tasks: makeTestTasks());
      expect(lists.ideals.length, 1);
      expect(lists.realities.length, 1);
      expect(lists.ideals[0].id, 'o1');
      expect(lists.realities[0].id, 'o2');
    });
  });

  group('statusColor', () {
    test('pending 返回灰色', () {
      expect(statusColor('pending'), const Color(0xFFAAAAAA));
    });
    test('confirmed 返回深色', () {
      expect(statusColor('confirmed'), const Color(0xFF444444));
    });
    test('null 返回灰色', () {
      expect(statusColor(null), const Color(0xFFAAAAAA));
    });
  });

  group('taskStatusColor', () {
    test('todo 返回浅灰', () {
      expect(taskStatusColor('todo'), const Color(0xFFBBBBBB));
    });
    test('doing 返回中灰', () {
      expect(taskStatusColor('doing'), const Color(0xFF666666));
    });
    test('done 返回深灰', () {
      expect(taskStatusColor('done'), const Color(0xFF444444));
    });
    test('blocked 返回中灰', () {
      expect(taskStatusColor('blocked'), const Color(0xFF999999));
    });
    test('null 返回浅灰', () {
      expect(taskStatusColor(null), const Color(0xFFBBBBBB));
    });
  });

  group('taskStatusLabel', () {
    test('todo 返回待开始', () {
      expect(taskStatusLabel('todo'), '待开始');
    });
    test('doing 返回进行中', () {
      expect(taskStatusLabel('doing'), '进行中');
    });
    test('done 返回已完成', () {
      expect(taskStatusLabel('done'), '已完成');
    });
    test('blocked 返回受阻', () {
      expect(taskStatusLabel('blocked'), '受阻');
    });
    test('null 返回待开始', () {
      expect(taskStatusLabel(null), '待开始');
    });
  });
}

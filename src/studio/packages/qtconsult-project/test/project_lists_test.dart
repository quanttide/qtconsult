import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtconsult_project/qtconsult_project.dart';

Project makeTestProject() {
  return Project(
    name: 'test',
    title: '测试项目',
    board: Board(lists: {
      'observe': BoardList(name: 'observe', cards: [
        BoardCard(id: 'o1', title: '调研卡片', description: '测试描述', category: 'ideal',
            custom: {'status': 'pending', 'source': '访谈'}),
        BoardCard(id: 'o2', title: '现实卡片', category: 'reality',
            custom: {'status': 'confirmed', 'source': '审计'}),
      ]),
      'orient': BoardList(name: 'orient', cards: [
        BoardCard(id: 'i1', title: '洞察测试', tags: {'domain': '技术领域'},
            custom: {'upstream': ['o1'], 'rootCause': '根因', 'impact': '影响'}),
      ]),
      'decide': BoardList(name: 'decide', cards: [
        BoardCard(id: 's1', title: '方案A',
            custom: {'upstream': ['i1'], 'advantage': '优势', 'isSelected': true}),
      ]),
      'act': BoardList(name: 'act', cards: [
        BoardCard(id: 't1', title: '任务1', assignee: '某人',
            custom: {'status': 'doing', 'progress': 0.5}),
      ]),
    }),
  );
}

void main() {
  group('ProjectLists', () {
    test('分析列按聚类分组', () {
      final project = makeTestProject();
      final clusters = project.lists.clusters;
      expect(clusters.length, 1);
      expect(clusters[0].name, '技术领域');
      expect(clusters[0].cards.length, 1);
    });

    test('Observe 卡片按 category 分组', () {
      final project = makeTestProject();
      expect(project.lists.ideals.length, 1);
      expect(project.lists.realities.length, 1);
      expect(project.lists.ideals[0].id, 'o1');
      expect(project.lists.realities[0].id, 'o2');
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

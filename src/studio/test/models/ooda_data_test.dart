import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtconsult_studio/models/ooda_data.dart';

Project makeTestProject() {
  return Project(
    name: 'test',
    title: '测试项目',
    lists: ProjectLists(
      observe: [
        BoardCard(id: 'o1', title: '调研卡片', description: '测试描述', category: 'ideal',
            custom: {'status': 'pending', 'source': '访谈'}),
        BoardCard(id: 'o2', title: '现实卡片', category: 'reality',
            custom: {'status': 'confirmed', 'source': '审计'}),
      ],
      orient: [
        BoardCard(id: 'i1', title: '洞察测试', types: '技术领域',
            upstream: ['o1'], custom: {'rootCause': '根因', 'impact': '影响'}),
      ],
      decide: [
        BoardCard(id: 's1', title: '方案A', upstream: ['i1'],
            custom: {'advantage': '优势', 'isSelected': true}),
      ],
      act: [
        BoardCard(id: 't1', title: '任务1', assignee: '某人',
            custom: {'status': 'doing', 'progress': 0.5}),
      ],
    ),
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

  group('BoardCard', () {
    test('copyWith 覆盖部分字段', () {
      final card = BoardCard(id: 'o1', title: '原标题', category: 'ideal',
          custom: {'status': 'pending'});
      final copied = card.copyWith(category: 'reality');
      expect(copied.id, 'o1');
      expect(copied.title, '原标题');
      expect(copied.category, 'reality');
      expect(copied.custom['status'], 'pending');
    });

    test('copyWith 不传参保留原值', () {
      final card = BoardCard(id: 'o1', title: '标题', category: 'ideal',
          custom: {});
      final copied = card.copyWith();
      expect(copied.title, '标题');
      expect(copied.category, 'ideal');
    });

    test('toJson 包含自定义字段', () {
      final card = BoardCard(id: 'o1', title: '卡片',
          custom: {'status': 'confirmed', 'source': '访谈'});
      final json = card.toJson();
      expect(json['id'], 'o1');
      expect(json['status'], 'confirmed');
      expect(json['source'], '访谈');
    });

    test('fromJson 分离自定义字段', () {
      final json = {
        'id': 'o1', 'title': '卡片', 'category': 'ideal',
        'status': 'confirmed', 'source': '访谈',
      };
      final card = BoardCard.fromJson(json);
      expect(card.category, 'ideal');
      expect(card.custom['status'], 'confirmed');
      expect(card.custom['source'], '访谈');
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

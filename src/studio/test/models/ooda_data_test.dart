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
}

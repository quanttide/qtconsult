import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qtconsult_studio/models/ooda_data.dart';
import 'package:qtconsult_studio/screens/ooda_screen.dart';
import 'package:qtconsult_studio/services/ooda_state.dart';
import 'package:qtconsult_studio/services/cache_service.dart';

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

Widget buildApp(Project project) {
  return ChangeNotifierProvider(
    create: (_) => OodaState(project, CacheService(filePath: '')),
    child: const MaterialApp(home: OodaScreen()),
  );
}

void main() {
  testWidgets('看板渲染卡片', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildApp(makeTestProject()));

    expect(find.text('咨询服务看板'), findsOneWidget);
    expect(find.text('调研卡片'), findsOneWidget);
    expect(find.text('洞察测试'), findsOneWidget);
    expect(find.text('方案A'), findsOneWidget);
    expect(find.text('任务1'), findsOneWidget);
  });

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

  test('toggleObserveConfirm 切换状态', () {
    final project = makeTestProject();
    final state = OodaState(project, CacheService(filePath: ''));
    expect(project.lists.observe[0].custom['status'], 'pending');

    state.toggleObserveConfirm('o1');
    expect(project.lists.observe[0].custom['status'], 'confirmed');
  });

  test('toggleStrategySelect 切换选中状态', () {
    final project = makeTestProject();
    final state = OodaState(project, CacheService(filePath: ''));
    expect(project.lists.decide[0].custom['isSelected'], true);

    state.toggleStrategySelect('s1');
    expect(project.lists.decide[0].custom['isSelected'], false);
  });

  test('updateClientNote 更新备注', () {
    final project = makeTestProject();
    final state = OodaState(project, CacheService(filePath: ''));
    expect(project.lists.decide[0].custom['clientNote'], isNull);

    state.updateClientNote('s1', '客户要求调整方案');
    expect(project.lists.decide[0].custom['clientNote'], '客户要求调整方案');
  });

  test('flush 保存到缓存', () async {
    final tmpDir = Directory.systemTemp.createTempSync('qtconsult_test_');
    addTearDown(() => tmpDir.deleteSync(recursive: true));
    final cachePath = '${tmpDir.path}/cache.json';
    final project = makeTestProject();
    final cache = CacheService(filePath: cachePath);
    final state = OodaState(project, cache);

    state.toggleObserveConfirm('o1');
    await state.flush();

    final cached = await cache.load();
    expect(cached, isNotNull);
    expect(cached!.lists.observe[0].custom['status'], 'confirmed');
  });

  test('OodaState 持有 workspaceId 和 projectId', () {
    final project = makeTestProject();
    final state = OodaState(project, CacheService(filePath: ''),
        workspaceId: 'ws1', projectId: 'test');
    // Verify state was constructed without error (workspaceId/projectId
    // are used internally by flush() for provider calls)
    expect(state.hasUnsavedChanges, false);
    state.toggleObserveConfirm('o1');
    expect(state.hasUnsavedChanges, true);
  });

  testWidgets('看板渲染加载警告', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final project = makeTestProject();
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => OodaState(project, CacheService(filePath: '')),
        child: const MaterialApp(home: OodaScreen(loadWarning: 'Provider 不可用，使用缓存数据')),
      ),
    );

    expect(find.text('Provider 不可用，使用缓存数据'), findsOneWidget);
  });
}

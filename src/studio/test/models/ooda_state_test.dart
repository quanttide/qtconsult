import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qtconsult_studio/models/ooda_data.dart';
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

void main() {
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
    expect(state.hasUnsavedChanges, false);
    state.toggleObserveConfirm('o1');
    expect(state.hasUnsavedChanges, true);
  });
}

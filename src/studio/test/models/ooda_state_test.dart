import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:qtconsult_project/qtconsult_project.dart';
import 'package:qtconsult_studio/services/ooda_state.dart';
import 'package:qtconsult_studio/services/cache_service.dart';
import 'package:qtconsult_studio/services/provider_service.dart';

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
            custom: {'upstream': ['o1'], 'cause': '根因', 'effect': '影响'}),
      ]),
      'decide': BoardList(name: 'decide', cards: [
        BoardCard(id: 's1', title: '方案A',
            custom: {'upstream': ['i1'], 'advantage': '优势', 'isSelected': true, 'clientNote': null}),
      ]),
      'act': BoardList(name: 'act', cards: [
        BoardCard(id: 't1', title: '任务1', assignee: '某人',
            custom: {'status': 'doing', 'progress': 0.5}),
      ]),
    }),
  );
}

class _MockClient extends http.BaseClient {
  final requests = <http.BaseRequest>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    final body = jsonEncode({});
    final stream = http.ByteStream.fromBytes(utf8.encode(body));
    final headers = {'content-type': 'application/json; charset=utf-8'};
    return http.StreamedResponse(stream, 200, headers: headers);
  }
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

  test('flush 通过 provider 更新卡片', () async {
    final mock = _MockClient();
    final provider = ProviderService(
      baseUrl: 'http://localhost:8756',
      client: mock,
    );
    final project = makeTestProject();
    final state = OodaState(project, CacheService(filePath: ''),
        provider: provider, workspaceId: 'ws1', projectId: 'test');

    state.toggleObserveConfirm('o1');
    await state.flush();

    final match = mock.requests.any((r) =>
        r.url.toString() ==
            'http://localhost:8756/workspaces/ws1/projects/test/cards/o1' &&
        r.method == 'PUT');
    expect(match, true);
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

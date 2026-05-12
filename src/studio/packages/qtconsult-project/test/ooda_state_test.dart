import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:data_sources/cache_service.dart';
import 'package:data_sources/provider_service.dart';
import 'package:qtconsult_project/qtconsult_project.dart';

List<Task> makeTestTasks() {
  return [
    Task(id: 'o1', title: '调研卡片', description: '测试描述', type: 'clarify',
        tags: {'source': '访谈'}, status: 'pending'),
    Task(id: 'o2', title: '现实卡片', type: 'research',
        tags: {'source': '审计'}, status: 'confirmed'),
    Task(id: 'i1', title: '洞察测试', type: 'orient',
        tags: {'domain': '技术领域', 'rootCause': '根因', 'impact': '影响'}),
    Task(id: 's1', title: '方案A', type: 'decide',
        tags: {'advantage': '优势', 'isSelected': 'true', 'clientNote': ''}),
    Task(id: 't1', title: '任务1', type: 'act', assignee: '某人', status: 'doing',
        tags: {'progress': '0.5'}),
  ];
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
    final tasks = makeTestTasks();
    final state = OodaState(tasks, CacheService(filePath: ''));
    expect(tasks[0].status, 'pending');

    state.toggleObserveConfirm('o1');
    expect(tasks[0].status, 'confirmed');
  });

  test('toggleStrategySelect 切换选中状态', () {
    final tasks = makeTestTasks();
    final state = OodaState(tasks, CacheService(filePath: ''));
    expect(tasks[3].tags['isSelected'], 'true');

    state.toggleStrategySelect('s1');
    expect(tasks[3].tags['isSelected'], isNull);
  });

  test('updateClientNote 更新备注', () {
    final tasks = makeTestTasks();
    final state = OodaState(tasks, CacheService(filePath: ''));
    expect(tasks[3].tags['clientNote'], '');

    state.updateClientNote('s1', '客户要求调整方案');
    expect(tasks[3].tags['clientNote'], '客户要求调整方案');
  });

  test('flush 保存到缓存', () async {
    final tmpDir = Directory.systemTemp.createTempSync('qtconsult_test_');
    addTearDown(() => tmpDir.deleteSync(recursive: true));
    final cachePath = '${tmpDir.path}/cache.json';
    final tasks = makeTestTasks();
    final cache = CacheService(filePath: cachePath);
    final state = OodaState(tasks, cache);

    state.toggleObserveConfirm('o1');
    await state.flush();

    final cachedRaw = await cache.load();
    expect(cachedRaw, isNotNull);
    final decoded = jsonDecode(cachedRaw!) as List<dynamic>;
    final list = decoded.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
    expect(list[0].status, 'confirmed');
  });

  test('flush 通过 provider 更新卡片', () async {
    final mock = _MockClient();
    final provider = ProviderService(
      baseUrl: 'http://localhost:8756',
      client: mock,
    );
    final tasks = makeTestTasks();
    final state = OodaState(tasks, CacheService(filePath: ''),
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
    final tasks = makeTestTasks();
    final state = OodaState(tasks, CacheService(filePath: ''),
        workspaceId: 'ws1', projectId: 'test');
    expect(state.hasUnsavedChanges, false);
    state.toggleObserveConfirm('o1');
    expect(state.hasUnsavedChanges, true);
  });
}

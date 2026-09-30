import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
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
      tags: {'source': '审计'},
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
      tags: {'advantage': '优势', 'isSelected': 'true', 'clientNote': ''},
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
  test('toggleClarifyConfirm 切换状态', () {
    final cubit = ConsultCubit(makeTestTasks(), CacheService(filePath: ''));
    addTearDown(cubit.close);
    expect(cubit.state.tasks[0].status, 'pending');

    cubit.toggleClarifyConfirm('o1');
    expect(cubit.state.tasks[0].status, 'confirmed');
  });

  test('toggleStrategySelect 切换选中状态', () {
    final cubit = ConsultCubit(makeTestTasks(), CacheService(filePath: ''));
    addTearDown(cubit.close);
    expect(cubit.state.tasks[3].tags['isSelected'], 'true');

    cubit.toggleStrategySelect('s1');
    expect(cubit.state.tasks[3].tags['isSelected'], isNull);
  });

  test('updateClientNote 更新备注', () {
    final cubit = ConsultCubit(makeTestTasks(), CacheService(filePath: ''));
    addTearDown(cubit.close);
    expect(cubit.state.tasks[3].tags['clientNote'], '');

    cubit.updateClientNote('s1', '客户要求调整方案');
    expect(cubit.state.tasks[3].tags['clientNote'], '客户要求调整方案');
  });

  test('flush 保存到缓存', () async {
    final tmpDir = Directory.systemTemp.createTempSync('qtconsult_test_');
    addTearDown(() => tmpDir.deleteSync(recursive: true));
    final cachePath = '${tmpDir.path}/cache.json';
    final cache = CacheService(filePath: cachePath);
    final cubit = ConsultCubit(makeTestTasks(), cache);
    addTearDown(cubit.close);

    cubit.toggleClarifyConfirm('o1');
    await cubit.flush();

    final cachedRaw = await cache.load();
    expect(cachedRaw, isNotNull);
    final decoded = jsonDecode(cachedRaw!) as List<dynamic>;
    final list = decoded
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
    expect(list[0].status, 'confirmed');
    expect(cubit.state.hasUnsavedChanges, false);
  });

  test('flush 通过 provider 更新卡片', () async {
    final mock = _MockClient();
    final provider = ProviderService(
      baseUrl: 'http://localhost:8756',
      client: mock,
    );
    final cubit = ConsultCubit(
      makeTestTasks(),
      CacheService(filePath: ''),
      provider: provider,
      workspaceId: 'ws1',
      projectId: 'test',
    );
    addTearDown(cubit.close);

    cubit.toggleClarifyConfirm('o1');
    await cubit.flush();

    final match = mock.requests.any(
      (r) =>
          r.url.toString() ==
              'http://localhost:8756/workspaces/ws1/projects/test/cards/o1' &&
          r.method == 'PUT',
    );
    expect(match, true);
  });

  test('交互后标记未回写改动，flush 后清除', () {
    final cubit = ConsultCubit(
      makeTestTasks(),
      CacheService(filePath: ''),
      workspaceId: 'ws1',
      projectId: 'test',
    );
    addTearDown(cubit.close);
    expect(cubit.state.hasUnsavedChanges, false);

    cubit.toggleClarifyConfirm('o1');
    expect(cubit.state.hasUnsavedChanges, true);
  });
}

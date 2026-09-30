import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:qtconsult_studio/qtconsult_studio.dart';

const _workspacesJson = '[{"id":"ws1","name":"工作区A","project_ids":["p1"]}]';

const _projectJson = '''
{
  "id": "p1",
  "name": "p1",
  "title": "项目A",
  "tasks": [
    {"id": "t1", "title": "任务1", "type": "clarify", "tags": {}, "status": "pending"},
    {"id": "t2", "title": "任务2", "type": "execute", "tags": {}, "status": "pending"}
  ]
}
''';

class _MockClient extends http.BaseClient {
  final responses = <String, String>{
    'GET http://localhost:8756/workspaces': _workspacesJson,
    'GET http://localhost:8756/workspaces/ws1/projects/p1': _projectJson,
  };

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final key = '${request.method} ${request.url}';
    final body = responses[key];
    if (body == null) {
      return http.StreamedResponse(const Stream<List<int>>.empty(), 404);
    }
    return http.StreamedResponse(
      http.ByteStream.fromBytes(utf8.encode(body)),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}

class _FailingClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return Future.error(Exception('provider down'));
  }
}

Future<String> _fileAsset(String path) async => File(path).readAsStringSync();

Future<String> _missingAsset(String path) async =>
    throw StateError('missing asset: $path');

CacheService _cacheFor(String wid, String pid) => CacheService(filePath: '');

AppCubit _cubit({ProviderService? provider, AssetLoader? loadAsset}) {
  return AppCubit(
    provider: provider,
    cacheBuilder: _cacheFor,
    loadAsset: loadAsset ?? _missingAsset,
  );
}

void main() {
  test('load 优先使用 provider 数据源', () async {
    final cubit = _cubit(
      provider: ProviderService(
        baseUrl: 'http://localhost:8756',
        client: _MockClient(),
      ),
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status, AppStatus.success);
    expect(cubit.state.currentWsId, 'ws1');
    expect(cubit.state.currentProjectId, 'p1');
    expect(cubit.state.workspaces!.single.name, '工作区A');
    expect(cubit.state.project!.title, '项目A');
    expect(cubit.state.tasks, hasLength(2));
  });

  test('provider 不可用时回退 fixture', () async {
    final cubit = _cubit(
      provider: ProviderService(
        baseUrl: 'http://localhost:8756',
        client: _FailingClient(),
      ),
      loadAsset: _fileAsset,
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status, AppStatus.success);
    expect(cubit.state.currentWsId, 'workspace0');
    expect(cubit.state.currentProjectId, 'project0');
    expect(cubit.state.project!.name, 'project0');
    expect(cubit.state.tasks, hasLength(18));
    expect(cubit.state.workspaces!.map((w) => w.id), [
      'workspace0',
      'workspace1',
    ]);
  });

  test('数据源全部失败进入 noData', () async {
    final cubit = _cubit();
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status, AppStatus.noData);
    expect(cubit.state.loadWarning, isNotNull);
    expect(cubit.state.workspaces, isNotNull);
  });

  test('切换工作区加载对应 fixture', () async {
    final cubit = _cubit(loadAsset: _fileAsset);
    addTearDown(cubit.close);

    await cubit.load();
    expect(cubit.state.currentWsId, 'workspace0');

    await cubit.switchWorkspace('workspace1');

    expect(cubit.state.status, AppStatus.success);
    expect(cubit.state.currentWsId, 'workspace1');
    expect(cubit.state.currentProjectId, 'project1');
    expect(cubit.state.project!.name, 'project1');
    expect(cubit.state.tasks, hasLength(20));
  });

  test('切换到当前工作区保持状态不变', () async {
    final cubit = _cubit(loadAsset: _fileAsset);
    addTearDown(cubit.close);

    await cubit.load();
    final before = cubit.state;

    await cubit.switchWorkspace('workspace0');

    expect(identical(cubit.state, before), isTrue);
  });

  test('切换到未知工作区保持状态不变', () async {
    final cubit = _cubit(loadAsset: _fileAsset);
    addTearDown(cubit.close);

    await cubit.load();
    final before = cubit.state;

    await cubit.switchWorkspace('nope');

    expect(identical(cubit.state, before), isTrue);
  });
}

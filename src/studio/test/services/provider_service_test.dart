import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:qtconsult_studio/models/ooda_data.dart';
import 'package:qtconsult_studio/services/provider_service.dart';

class _MockClient extends http.BaseClient {
  final Map<String, _MockResponse> _responses = {};

  void expect(String method, String url, int status, dynamic body) {
    _responses['$method $url'] = _MockResponse(status, body);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final key = '${request.method} ${request.url.toString()}';
    final resp = _responses[key];
    if (resp == null) {
      throw Exception('No mock for $key');
    }
    final body = jsonEncode(resp.body);
    final stream = http.ByteStream.fromBytes(utf8.encode(body));
    final headers = {'content-type': 'application/json; charset=utf-8'};
    return Future.value(http.StreamedResponse(stream, resp.status, headers: headers));
  }
}

class _MockResponse {
  final int status;
  final dynamic body;
  const _MockResponse(this.status, this.body);
}

void main() {
  late _MockClient mock;
  late ProviderService service;

  setUp(() {
    mock = _MockClient();
    service = ProviderService(
      baseUrl: 'http://localhost:8756',
      apiToken: '',
      client: mock,
    );
  });

  group('listWorkspaces', () {
    test('返回工作区列表', () async {
      mock.expect('GET', 'http://localhost:8756/workspaces', 200, [
        {'id': 'ws1', 'name': '工作区A', 'project_ids': ['p1']},
        {'id': 'ws2', 'name': '工作区B', 'project_ids': ['p2', 'p3']},
      ]);
      final workspaces = await service.listWorkspaces();
      expect(workspaces.length, 2);
      expect(workspaces[0].id, 'ws1');
      expect(workspaces[0].name, '工作区A');
      expect(workspaces[0].projectIds, ['p1']);
      expect(workspaces[1].projectIds, ['p2', 'p3']);
    });

    test('非200抛出异常', () async {
      mock.expect('GET', 'http://localhost:8756/workspaces', 500, {});
      expect(() => service.listWorkspaces(), throwsA(isA<ProviderException>()));
    });
  });

  group('loadProject', () {
    test('返回项目数据', () async {
      mock.expect(
          'GET', 'http://localhost:8756/workspaces/ws1/projects/p1', 200, {
        'name': 'p1',
        'title': '测试项目',
        'lists': {
          'observe': [{'id': 'o1', 'title': '卡片1', 'category': 'ideal'}],
          'orient': [],
          'decide': [],
          'act': [],
        }
      });
      final project = await service.loadProject('ws1', 'p1');
      expect(project.name, 'p1');
      expect(project.title, '测试项目');
      expect(project.lists.observe.length, 1);
      expect(project.lists.observe[0].title, '卡片1');
    });

    test('非200抛出异常', () async {
      mock.expect(
          'GET', 'http://localhost:8756/workspaces/ws1/projects/p1', 404, {});
      expect(() => service.loadProject('ws1', 'p1'),
          throwsA(isA<ProviderException>()));
    });
  });

  group('updateCard', () {
    test('正常更新不抛异常', () async {
      mock.expect(
          'PUT',
          'http://localhost:8756/workspaces/ws1/projects/p1/cards/o1',
          200,
          {'id': 'o1', 'title': '已更新'});
      final card = BoardCard(id: 'o1', title: '已更新');
      await service.updateCard('ws1', 'p1', card);
    });

    test('非200抛出异常', () async {
      mock.expect(
          'PUT',
          'http://localhost:8756/workspaces/ws1/projects/p1/cards/o1',
          404,
          {});
      final card = BoardCard(id: 'o1', title: 'x');
      expect(() => service.updateCard('ws1', 'p1', card),
          throwsA(isA<ProviderException>()));
    });
  });
}

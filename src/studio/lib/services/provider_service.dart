import 'dart:convert';

import 'package:http/http.dart' as http;

/// 工作区信息：id、名称及所含项目 id 列表。
class WorkspaceInfo {
  /// 工作区 id。
  final String id;

  /// 工作区显示名称。
  final String name;

  /// 工作区内包含的项目 id 列表。
  final List<String> projectIds;

  /// 创建工作区信息。
  const WorkspaceInfo({
    required this.id,
    required this.name,
    required this.projectIds,
  });

  /// 从 `workspaces` 接口的 JSON 对象解析工作区信息。
  factory WorkspaceInfo.fromJson(Map<String, dynamic> json) {
    return WorkspaceInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      projectIds: (json['project_ids'] as List<dynamic>).cast<String>(),
    );
  }
}

/// provider HTTP 客户端：封装工作区列表、项目读取与卡片回写接口。
class ProviderService {
  /// 服务根地址（已去除尾部斜杠）。
  final Uri baseUri;

  /// Bearer 令牌；为空时不携带鉴权头。
  final String apiToken;

  final http.Client _client;

  /// 创建 provider 客户端，`client` 可注入以便测试。
  ProviderService({
    required String baseUrl,
    this.apiToken = '',
    http.Client? client,
  }) : baseUri = Uri.parse(baseUrl.replaceFirst(RegExp(r'/$'), '')),
       _client = client ?? http.Client();

  /// 拉取全部工作区；非 200 响应抛出 [ProviderException]。
  Future<List<WorkspaceInfo>> listWorkspaces() async {
    final response = await _client.get(baseUri.resolve('/workspaces'));
    if (response.statusCode != 200) {
      throw ProviderException('Failed to list workspaces', response.statusCode);
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => WorkspaceInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 加载指定工作区下的项目 JSON；非 200 响应抛出 [ProviderException]。
  Future<Map<String, dynamic>> loadProject(
    String workspaceId,
    String projectId,
  ) async {
    final response = await _client.get(
      baseUri.resolve('/workspaces/$workspaceId/projects/$projectId'),
    );
    if (response.statusCode != 200) {
      throw ProviderException('Failed to load project', response.statusCode);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// 回写单张卡片；非 200 响应抛出 [ProviderException]。
  Future<void> updateCard(
    String workspaceId,
    String projectId,
    Map<String, dynamic> card,
  ) async {
    final response = await _client.put(
      baseUri.resolve(
        '/workspaces/$workspaceId/projects/$projectId/cards/${Uri.encodeComponent(card['id'] as String)}',
      ),
      headers: _headers,
      body: jsonEncode(card),
    );
    if (response.statusCode != 200) {
      throw ProviderException(
        'Failed to update card ${card['id']}',
        response.statusCode,
      );
    }
  }

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (apiToken.isNotEmpty) 'Authorization': 'Bearer $apiToken',
    };
  }
}

/// provider 接口调用异常，携带失败原因与 HTTP 状态码。
class ProviderException implements Exception {
  /// 失败原因描述。
  final String message;

  /// HTTP 状态码。
  final int statusCode;

  /// 创建 provider 异常。
  ProviderException(this.message, this.statusCode);

  @override
  String toString() => '$message ($statusCode)';
}

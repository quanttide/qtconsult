import 'dart:convert';

import 'package:http/http.dart' as http;

class WorkspaceInfo {
  final String id;
  final String name;
  final List<String> projectIds;

  const WorkspaceInfo({
    required this.id,
    required this.name,
    required this.projectIds,
  });

  factory WorkspaceInfo.fromJson(Map<String, dynamic> json) {
    return WorkspaceInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      projectIds: (json['project_ids'] as List<dynamic>).cast<String>(),
    );
  }
}

class ProviderService {
  final Uri baseUri;
  final String apiToken;
  final http.Client _client;

  ProviderService({
    required String baseUrl,
    this.apiToken = '',
    http.Client? client,
  })  : baseUri = Uri.parse(baseUrl.replaceFirst(RegExp(r'/$'), '')),
        _client = client ?? http.Client();

  Future<List<WorkspaceInfo>> listWorkspaces() async {
    final response = await _client.get(baseUri.resolve('/workspaces'));
    if (response.statusCode != 200) {
      throw ProviderException('Failed to list workspaces', response.statusCode);
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => WorkspaceInfo.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> loadProject(String workspaceId, String projectId) async {
    final response = await _client.get(
      baseUri.resolve('/workspaces/$workspaceId/projects/$projectId'),
    );
    if (response.statusCode != 200) {
      throw ProviderException('Failed to load project', response.statusCode);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> updateCard(String workspaceId, String projectId, Map<String, dynamic> card) async {
    final response = await _client.put(
      baseUri.resolve('/workspaces/$workspaceId/projects/$projectId/cards/${Uri.encodeComponent(card['id'] as String)}'),
      headers: _headers,
      body: jsonEncode(card),
    );
    if (response.statusCode != 200) {
      throw ProviderException('Failed to update card ${card['id']}', response.statusCode);
    }
  }

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (apiToken.isNotEmpty) 'Authorization': 'Bearer $apiToken',
    };
  }
}

class ProviderException implements Exception {
  final String message;
  final int statusCode;

  ProviderException(this.message, this.statusCode);

  @override
  String toString() => '$message ($statusCode)';
}

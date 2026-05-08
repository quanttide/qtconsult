import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:qtconsult_studio/models/ooda_data.dart';

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

  Future<Project> loadProject() async {
    final response = await _client.get(baseUri.resolve('/project'));
    if (response.statusCode != 200) {
      throw ProviderException('Failed to load project', response.statusCode);
    }
    return Project.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> updateCard(BoardCard card) async {
    final response = await _client.put(
      baseUri.resolve('/project/cards/${Uri.encodeComponent(card.id)}'),
      headers: _headers,
      body: jsonEncode(card.toJson()),
    );
    if (response.statusCode != 200) {
      throw ProviderException('Failed to update card ${card.id}', response.statusCode);
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

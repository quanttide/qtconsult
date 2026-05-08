import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:qtconsult_studio/models/ooda_data.dart';

class CacheService {
  final String filePath;

  CacheService({required this.filePath});

  Future<Project?> load() async {
    try {
      final raw = html.window.localStorage[filePath];
      if (raw == null || raw.isEmpty) return null;
      return Project.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Cache load error: $e');
      return null;
    }
  }

  Future<void> save(Project project) async {
    try {
      html.window.localStorage[filePath] = jsonEncode(project.toJson());
    } catch (e) {
      debugPrint('Cache save error: $e');
    }
  }
}

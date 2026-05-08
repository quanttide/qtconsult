import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:qtconsult_studio/models/ooda_data.dart';

class CacheService {
  final String filePath;

  CacheService({required this.filePath});

  Future<Project?> load() async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      return Project.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Cache load error: $e');
      return null;
    }
  }

  Future<void> save(Project project) async {
    try {
      final file = File(filePath);
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(project.toJson()));
    } catch (e) {
      debugPrint('Cache save error: $e');
    }
  }
}

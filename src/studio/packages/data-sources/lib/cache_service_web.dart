import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';

class CacheService {
  final String filePath;

  CacheService({required this.filePath});

  Future<String?> load() async {
    try {
      final raw = html.window.localStorage[filePath];
      if (raw == null || raw.isEmpty) return null;
      return raw;
    } catch (e) {
      debugPrint('Cache load error: $e');
      return null;
    }
  }

  Future<void> save(String data) async {
    try {
      html.window.localStorage[filePath] = data;
    } catch (e) {
      debugPrint('Cache save error: $e');
    }
  }
}

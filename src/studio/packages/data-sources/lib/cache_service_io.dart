import 'dart:io';

import 'package:flutter/foundation.dart';

class CacheService {
  final String filePath;

  CacheService({required this.filePath});

  Future<String?> load() async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;
      return await file.readAsString();
    } catch (e) {
      debugPrint('Cache load error: $e');
      return null;
    }
  }

  Future<void> save(String data) async {
    try {
      final file = File(filePath);
      await file.parent.create(recursive: true);
      await file.writeAsString(data);
    } catch (e) {
      debugPrint('Cache save error: $e');
    }
  }
}

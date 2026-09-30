import 'dart:io';

import 'package:flutter/foundation.dart';

/// 基于文件的缓存实现（仅限原生平台）。
class CacheService {
  /// 缓存文件路径。
  final String filePath;

  /// 创建指向 `filePath` 的文件缓存。
  CacheService({required this.filePath});

  /// 读取缓存内容；文件不存在或读取失败返回 `null`。
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

  /// 写入缓存内容，自动创建父目录；失败仅记录日志不抛出。
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

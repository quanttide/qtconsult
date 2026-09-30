import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// 基于 localStorage 的缓存实现（仅限 Web 平台）。
class CacheService {
  /// 缓存键。
  final String filePath;

  /// 创建以 `filePath` 为键的 localStorage 缓存。
  CacheService({required this.filePath});

  /// 读取缓存内容；键不存在或为空返回 `null`。
  Future<String?> load() async {
    try {
      final raw = web.window.localStorage.getItem(filePath);
      if (raw == null || raw.isEmpty) return null;
      return raw;
    } catch (e) {
      debugPrint('Cache load error: $e');
      return null;
    }
  }

  /// 写入缓存内容；失败仅记录日志不抛出。
  Future<void> save(String data) async {
    try {
      web.window.localStorage.setItem(filePath, data);
    } catch (e) {
      debugPrint('Cache save error: $e');
    }
  }
}

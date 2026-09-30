/// 空缓存实现：不做任何持久化，作为不支持存储平台的占位。
class CacheService {
  /// 缓存键（占位，不实际使用）。
  final String filePath;

  /// 创建空缓存。
  CacheService({required this.filePath});

  /// 恒返回 `null`，即无缓存数据。
  Future<String?> load() async => null;

  /// 丢弃写入内容。
  Future<void> save(String data) async {}
}

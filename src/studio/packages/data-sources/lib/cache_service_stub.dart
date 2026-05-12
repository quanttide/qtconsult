class CacheService {
  final String filePath;

  CacheService({required this.filePath});

  Future<String?> load() async => null;

  Future<void> save(String data) async {}
}

import 'cache_service.dart';

/// 项目缓存默认落点：`data/cache/{wid}/{pid}.json`。
CacheService projectCache(String wid, String pid) =>
    CacheService(filePath: 'data/cache/$wid/$pid.json');

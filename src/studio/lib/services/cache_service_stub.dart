import 'package:qtconsult_studio/models/ooda_data.dart';

class CacheService {
  final String filePath;

  CacheService({required this.filePath});

  Future<Project?> load() async => null;

  Future<void> save(Project project) async {}
}

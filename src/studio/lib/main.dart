import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qtconsult_studio/models/ooda_data.dart';
import 'package:qtconsult_studio/screens/ooda_screen.dart';
import 'package:qtconsult_studio/services/cache_service.dart';
import 'package:qtconsult_studio/services/ooda_state.dart';
import 'package:qtconsult_studio/services/provider_service.dart';

String get cachePath {
  const value = String.fromEnvironment(
    'QTCONSULT_STUDIO_CACHE_PATH',
    defaultValue: 'qtconsult:project1',
  );
  return value;
}

String get providerUrl {
  return const String.fromEnvironment('QTCONSULT_PROVIDER_URL');
}

String get providerToken {
  return const String.fromEnvironment('QTCONSULT_API_TOKEN');
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QtConsultStudio());
}

class QtConsultStudio extends StatelessWidget {
  const QtConsultStudio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '量潮咨询服务看板',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
      ),
      home: const _AppLoader(),
    );
  }
}

class _AppLoader extends StatefulWidget {
  const _AppLoader();

  @override
  State<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<_AppLoader> {
  Project? _project;
  CacheService? _cache;
  ProviderService? _provider;
  String? _loadWarning;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cache = CacheService(filePath: cachePath);
    final provider = providerUrl.isNotEmpty
        ? ProviderService(baseUrl: providerUrl, apiToken: providerToken)
        : null;
    Project? project;
    String? loadWarning;
    if (provider != null) {
      try {
        project = await provider.loadProject();
        await cache.save(project);
      } catch (e) {
        loadWarning = 'Provider load failed: $e';
      }
    }
    project ??= await cache.load();
    if (project == null) {
      final raw = await rootBundle.loadString('assets/fixtures/projects/project1.json');
      project = Project.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      await cache.save(project);
    }
    if (mounted) {
      setState(() {
        _project = project;
        _cache = cache;
        _provider = provider;
        _loadWarning = loadWarning;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_project == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在加载数据……', style: TextStyle(color: Color(0xFF999999))),
            ],
          ),
        ),
      );
    }
    return ChangeNotifierProvider(
      create: (_) => OodaState(_project!, _cache!, provider: _provider),
      child: OodaScreen(loadWarning: _loadWarning),
    );
  }
}

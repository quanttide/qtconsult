import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qtconsult_studio/models/ooda_data.dart';
import 'package:qtconsult_studio/screens/ooda_screen.dart';
import 'package:qtconsult_studio/services/cache_service.dart';
import 'package:qtconsult_studio/services/ooda_state.dart';

String get cachePath {
  final env = Platform.environment['QTCONSULT_CACHE_PATH'];
  if (env != null && env.isNotEmpty) return env;
  final define = const String.fromEnvironment('CACHE_PATH');
  if (define.isNotEmpty) return define;
  return 'data/project.json';
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cache = CacheService(filePath: cachePath);
    final project = await cache.load();
    if (mounted) {
      setState(() {
        _project = project;
        _cache = cache;
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
      create: (_) => OodaState(_project!, _cache!),
      child: const OodaScreen(),
    );
  }
}

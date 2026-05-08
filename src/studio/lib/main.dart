import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qtconsult_studio/models/ooda_data.dart';
import 'package:qtconsult_studio/screens/ooda_screen.dart';
import 'package:qtconsult_studio/screens/workspace_select_screen.dart';
import 'package:qtconsult_studio/services/cache_service.dart';
import 'package:qtconsult_studio/services/ooda_state.dart';
import 'package:qtconsult_studio/services/provider_service.dart';

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
  @override
  void initState() {
    super.initState();
  }

  CacheService _buildCache(String wid, String pid) {
    return CacheService(filePath: 'qtconsult:$wid:$pid');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_LoadResult>(
      future: _loadData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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
        final result = snapshot.data;
        if (result == null) {
          return const Scaffold(
            body: Center(child: Text('加载失败', style: TextStyle(color: Colors.red))),
          );
        }
        if (result.workspaces != null) {
          return WorkspaceSelectScreen(
            workspaces: result.workspaces!,
            cacheBuilder: _buildCache,
            provider: result.provider,
          );
        }
        if (result.project != null) {
          return ChangeNotifierProvider(
            create: (_) => OodaState(
              result.project!,
              _buildCache('workspace0', result.project!.name),
              provider: result.provider,
              workspaceId: 'workspace0',
              projectId: result.project!.name,
            ),
            child: OodaScreen(loadWarning: result.loadWarning),
          );
        }
        return const Scaffold(
          body: Center(child: Text('无可用的项目数据', style: TextStyle(color: Colors.red))),
        );
      },
    );
  }
}

class _LoadResult {
  final List<WorkspaceInfo>? workspaces;
  final Project? project;
  final ProviderService? provider;
  final String? loadWarning;

  const _LoadResult({this.workspaces, this.project, this.provider, this.loadWarning});
}

Future<_LoadResult> _loadData() async {
  final provider = providerUrl.isNotEmpty
      ? ProviderService(baseUrl: providerUrl, apiToken: providerToken)
      : null;

  if (provider != null) {
    try {
      final workspaces = await provider.listWorkspaces();
      return _LoadResult(workspaces: workspaces, provider: provider);
    } catch (e) {
      // Provider works but listing workspaces failed; fall through to fallback
    }
  }

  // Fallback: try cache for default project
  final defaultCache = CacheService(filePath: 'qtconsult:workspace0:project0');
  Project? project = await defaultCache.load();
  String? loadWarning;

  if (project == null) {
    try {
      final raw = await rootBundle.loadString('assets/fixtures/workspace0/project0.json');
      project = Project.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      await defaultCache.save(project);
    } catch (_) {
      try {
        final raw = await rootBundle.loadString('assets/fixtures/workspace1/project1.json');
        project = Project.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        await defaultCache.save(project);
      } catch (e) {
        loadWarning = '所有数据源加载失败: $e';
      }
    }
  }

  return _LoadResult(project: project, provider: provider, loadWarning: loadWarning);
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:data_sources/cache_service.dart';
import 'package:data_sources/provider_service.dart';
import 'package:qtconsult_project/qtconsult_project.dart';

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
        if (result.project == null) {
          return const Scaffold(
            body: Center(child: Text('无可用的项目数据', style: TextStyle(color: Colors.red))),
          );
        }
        return _AppBody(
          key: ValueKey('${result.currentWsId}:${result.project!.name}'),
          workspaces: result.workspaces,
          currentWsId: result.currentWsId,
          project: result.project!,
          provider: result.provider,
          cacheBuilder: result.cacheBuilder,
          loadWarning: result.loadWarning,
        );
      },
    );
  }
}

class _AppBody extends StatefulWidget {
  final List<WorkspaceInfo>? workspaces;
  final String currentWsId;
  final Project project;
  final ProviderService? provider;
  final CacheService Function(String wid, String pid) cacheBuilder;
  final String? loadWarning;

  const _AppBody({
    super.key,
    required this.project,
    required this.currentWsId,
    required this.cacheBuilder,
    this.workspaces,
    this.provider,
    this.loadWarning,
  });

  @override
  State<_AppBody> createState() => _AppBodyState();
}

class _AppBodyState extends State<_AppBody> {
  late String _currentWsId;
  late String _currentPid;
  late Project _project;

  @override
  void initState() {
    super.initState();
    _currentWsId = widget.currentWsId;
    _currentPid = widget.project.name;
    _project = widget.project;
  }

  void _switchWorkspace(String wid) async {
    if (wid == _currentWsId) return;
    final ws = widget.workspaces!.firstWhere((w) => w.id == wid);
    if (ws.projectIds.isEmpty) return;
    final pid = ws.projectIds.first;

    if (widget.provider != null) {
      try {
        final json = await widget.provider!.loadProject(wid, pid);
        final project = Project.fromJson(json);
        final cache = widget.cacheBuilder(wid, pid);
        cache.save(jsonEncode(project.toJson()));
        setState(() {
          _currentWsId = wid;
          _currentPid = pid;
          _project = project;
        });
      } catch (_) {}
    } else {
      final cache = widget.cacheBuilder(wid, pid);
      final cachedRaw = await cache.load();
      Project? project;
      if (cachedRaw != null) {
        project = Project.fromJson(jsonDecode(cachedRaw) as Map<String, dynamic>);
      }
      if (project == null) {
        try {
          final raw = await rootBundle.loadString('assets/fixtures/$wid/$pid.json');
          project = Project.fromJson(jsonDecode(raw) as Map<String, dynamic>);
          await cache.save(jsonEncode(project.toJson()));
        } catch (_) {
          return;
        }
      }
      setState(() {
        _currentWsId = wid;
        _currentPid = pid;
        _project = project!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cache = widget.cacheBuilder(_currentWsId, _currentPid);
    return ChangeNotifierProvider(
      key: ValueKey('$_currentWsId:$_currentPid'),
      create: (_) => OodaState(
        _project,
        cache,
        provider: widget.provider,
        workspaceId: _currentWsId,
        projectId: _currentPid,
      ),
      child: OodaScreen(
        workspaces: widget.workspaces,
        currentWsId: _currentWsId,
        onSwitchWorkspace: widget.workspaces != null ? _switchWorkspace : null,
        loadWarning: widget.loadWarning,
      ),
    );
  }
}

class _LoadResult {
  final List<WorkspaceInfo>? workspaces;
  final Project? project;
  final ProviderService? provider;
  final CacheService Function(String wid, String pid) cacheBuilder;
  final String? loadWarning;
  final String currentWsId;

  const _LoadResult({
    this.workspaces,
    this.project,
    this.provider,
    required this.cacheBuilder,
    this.loadWarning,
    required this.currentWsId,
  });
}

Future<_LoadResult> _loadData() async {
  final provider = providerUrl.isNotEmpty
      ? ProviderService(baseUrl: providerUrl, apiToken: providerToken)
      : null;

  CacheService Function(String wid, String pid) cacheBuilder =
      (wid, pid) => CacheService(filePath: 'data/cache/$wid/$pid.json');

  if (provider != null) {
    try {
      final workspaces = await provider.listWorkspaces();
      if (workspaces.isNotEmpty) {
        final ws = workspaces.first;
        if (ws.projectIds.isNotEmpty) {
          final pid = ws.projectIds.first;
          final json = await provider.loadProject(ws.id, pid);
          final project = Project.fromJson(json);
          return _LoadResult(
            workspaces: workspaces,
            project: project,
            provider: provider,
            cacheBuilder: cacheBuilder,
            currentWsId: ws.id,
          );
        }
      }
    } catch (e) {
      // Provider failed; fall through to fallback
    }
  }

  // Fallback: try cache for default project
  final defaultCache = CacheService(filePath: 'data/cache/workspace0/project0.json');
  final cachedRaw = await defaultCache.load();
  Project? project;
  if (cachedRaw != null) {
    project = Project.fromJson(jsonDecode(cachedRaw) as Map<String, dynamic>);
  }
  String? loadWarning;

  if (project == null) {
    try {
      final raw = await rootBundle.loadString('assets/fixtures/workspace0/project0.json');
      project = Project.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      await defaultCache.save(jsonEncode(project.toJson()));
    } catch (_) {
      try {
        final raw = await rootBundle.loadString('assets/fixtures/workspace1/project1.json');
        project = Project.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        await defaultCache.save(jsonEncode(project.toJson()));
      } catch (e) {
        loadWarning = '所有数据源加载失败: $e';
      }
    }
  }

  final fallbackWorkspaces = [
    WorkspaceInfo(id: 'workspace0', name: '工作区 0', projectIds: ['project0']),
    WorkspaceInfo(id: 'workspace1', name: '工作区 1', projectIds: ['project1']),
  ];

  return _LoadResult(
    project: project,
    workspaces: fallbackWorkspaces,
    provider: provider,
    cacheBuilder: cacheBuilder,
    currentWsId: 'workspace0',
    loadWarning: loadWarning,
  );
}

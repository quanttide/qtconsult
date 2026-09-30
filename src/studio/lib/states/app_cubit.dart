import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:quanttide_project/quanttide_project.dart';

import '../services/cache_service.dart';
import '../services/project_cache.dart';
import '../services/provider_service.dart';
import 'app_state.dart';

/// 资源加载器签名，生产环境注入 `rootBundle.loadString`。
typedef AssetLoader = Future<String> Function(String path);

/// 按工作区与项目 id 构造项目缓存。
typedef CacheServiceBuilder = CacheService Function(String wid, String pid);

/// 应用数据加载与工作区切换逻辑。
///
/// 数据源优先级：provider API → 内置 fixture 资源。
class AppCubit extends Cubit<AppState> {
  /// 创建应用逻辑。
  ///
  /// [loadAsset] 注入资源读取（测试可替换实现），[cacheBuilder] 缺省为
  /// [projectCache]，测试可注入临时路径。[initialTarget] 为深链冷启动目标
  /// （`/:wid/:pid`），命中则优先加载，避免先落默认项目再切换的闪烁。
  AppCubit({
    ProviderService? provider,
    CacheServiceBuilder? cacheBuilder,
    required AssetLoader loadAsset,
    ({String wid, String pid})? initialTarget,
  }) : _provider = provider,
       _cacheBuilder = cacheBuilder ?? projectCache,
       _loadAsset = loadAsset,
       _initialTarget = initialTarget,
       super(
         AppState(
           status: AppStatus.loading,
           provider: provider,
           cacheBuilder: cacheBuilder ?? projectCache,
         ),
       );

  static const List<WorkspaceInfo> _fallbackWorkspaces = [
    WorkspaceInfo(id: 'workspace0', name: '工作区 0', projectIds: ['project0']),
    WorkspaceInfo(id: 'workspace1', name: '工作区 1', projectIds: ['project1']),
  ];

  final ProviderService? _provider;
  final CacheServiceBuilder _cacheBuilder;
  final AssetLoader _loadAsset;
  final ({String wid, String pid})? _initialTarget;

  /// 加载首个可用数据源：深链目标优先，其次 provider API，内置 fixture 兜底。
  Future<void> load() async {
    _emit(_state(AppStatus.loading));
    try {
      final target = _initialTarget;
      if (target != null) {
        final targeted = await _loadTarget(target.wid, target.pid);
        if (targeted != null) {
          _emit(targeted);
          return;
        }
      }
      final provider = _provider;
      if (provider != null) {
        final loaded = await _loadFromProvider(provider);
        if (loaded != null) {
          _emit(loaded);
          return;
        }
      }
      _emit(await _loadFromFixtures());
    } catch (error) {
      _emit(_state(AppStatus.failure, loadWarning: '$error'));
    }
  }

  /// 打开指定工作区/项目的看板；目标无效或加载失败时保持当前视图。
  Future<void> openProject(String wid, String pid) async {
    final current = state;
    if (wid == current.currentWsId && pid == current.currentProjectId) return;
    if (current.workspaces == null) return;
    try {
      final provider = _provider;
      final Map<String, dynamic> json;
      if (provider != null) {
        json = await provider.loadProject(wid, pid);
        await _cacheBuilder(wid, pid).save(jsonEncode(json));
      } else {
        json =
            jsonDecode(await _loadAsset('assets/fixtures/$wid/$pid.json'))
                as Map<String, dynamic>;
      }
      final parsed = _parseTasks(json);
      _emit(
        _state(
          AppStatus.success,
          workspaces: current.workspaces,
          currentWsId: wid,
          currentProjectId: pid,
          project: parsed.project,
          tasks: parsed.tasks,
        ),
      );
    } catch (_) {
      // 打开失败保持当前视图
    }
  }

  Future<AppState?> _loadTarget(String wid, String pid) async {
    final provider = _provider;
    if (provider != null) {
      try {
        final workspaces = await provider.listWorkspaces();
        if (workspaces.any((w) => w.id == wid)) {
          final json = await provider.loadProject(wid, pid);
          final parsed = _parseTasks(json);
          return _state(
            AppStatus.success,
            workspaces: workspaces,
            currentWsId: wid,
            currentProjectId: pid,
            project: parsed.project,
            tasks: parsed.tasks,
          );
        }
      } catch (_) {
        // 深链目标不可用，回退 fixture 目标
      }
    }
    final matches = _fallbackWorkspaces.where(
      (w) => w.id == wid && w.projectIds.contains(pid),
    );
    if (matches.isEmpty) return null;
    try {
      final json =
          jsonDecode(await _loadAsset('assets/fixtures/$wid/$pid.json'))
              as Map<String, dynamic>;
      final parsed = _parseTasks(json);
      return _state(
        AppStatus.success,
        workspaces: _fallbackWorkspaces,
        currentWsId: wid,
        currentProjectId: pid,
        project: parsed.project,
        tasks: parsed.tasks,
      );
    } catch (_) {
      return null;
    }
  }

  Future<AppState?> _loadFromProvider(ProviderService provider) async {
    try {
      final workspaces = await provider.listWorkspaces();
      if (workspaces.isEmpty) return null;
      final ws = workspaces.first;
      if (ws.projectIds.isEmpty) return null;
      final pid = ws.projectIds.first;
      final json = await provider.loadProject(ws.id, pid);
      final parsed = _parseTasks(json);
      return _state(
        AppStatus.success,
        workspaces: workspaces,
        currentWsId: ws.id,
        currentProjectId: pid,
        project: parsed.project,
        tasks: parsed.tasks,
      );
    } catch (_) {
      // provider 不可用，回退 fixture
      return null;
    }
  }

  Future<AppState> _loadFromFixtures() async {
    String? loadWarning;
    for (final ws in _fallbackWorkspaces) {
      for (final pid in ws.projectIds) {
        try {
          final json =
              jsonDecode(await _loadAsset('assets/fixtures/${ws.id}/$pid.json'))
                  as Map<String, dynamic>;
          final parsed = _parseTasks(json);
          return _state(
            AppStatus.success,
            workspaces: _fallbackWorkspaces,
            currentWsId: ws.id,
            currentProjectId: pid,
            project: parsed.project,
            tasks: parsed.tasks,
          );
        } catch (error) {
          loadWarning = '所有数据源加载失败: $error';
        }
      }
    }
    return _state(
      AppStatus.noData,
      workspaces: _fallbackWorkspaces,
      loadWarning: loadWarning,
    );
  }

  AppState _state(
    AppStatus status, {
    List<WorkspaceInfo>? workspaces,
    String currentWsId = '',
    String? currentProjectId,
    Project? project,
    List<Task>? tasks,
    String? loadWarning,
  }) {
    return AppState(
      status: status,
      provider: _provider,
      cacheBuilder: _cacheBuilder,
      workspaces: workspaces,
      currentWsId: currentWsId,
      currentProjectId: currentProjectId,
      project: project,
      tasks: tasks,
      loadWarning: loadWarning,
    );
  }

  void _emit(AppState state) {
    if (isClosed) return;
    emit(state);
  }

  ({Project project, List<Task> tasks}) _parseTasks(Map<String, dynamic> json) {
    return (
      project: Project.fromJson(json),
      tasks:
          (json['tasks'] as List?)
              ?.map((e) => Task.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

import 'package:quanttide_project/quanttide_project.dart';

import '../services/cache_service.dart';
import '../services/provider_service.dart';

/// 应用数据加载阶段。
enum AppStatus {
  /// 数据加载中。
  loading,

  /// 加载成功，可渲染看板。
  success,

  /// 所有数据源均失败。
  failure,

  /// 无任何可展示的项目数据。
  noData,
}

/// 应用状态：加载阶段、工作区与当前项目数据，以及数据源引用。
class AppState {
  /// 创建应用状态。
  const AppState({
    required this.status,
    required this.cacheBuilder,
    this.provider,
    this.workspaces,
    this.currentWsId = '',
    this.currentProjectId,
    this.project,
    this.tasks,
    this.loadWarning,
  });

  /// 当前加载阶段。
  final AppStatus status;

  /// 远端 provider 服务；为 `null` 时仅使用本地数据源。
  final ProviderService? provider;

  /// 按工作区与项目 id 构造项目缓存的工厂。
  final CacheService Function(String wid, String pid) cacheBuilder;

  /// 可切换的工作区列表。
  final List<WorkspaceInfo>? workspaces;

  /// 当前工作区 id。
  final String currentWsId;

  /// 当前项目 id。
  final String? currentProjectId;

  /// 当前项目定义。
  final Project? project;

  /// 当前项目任务列表。
  final List<Task>? tasks;

  /// 数据加载警告，非空时在看板顶部横幅展示。
  final String? loadWarning;
}

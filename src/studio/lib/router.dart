import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'qtconsult_studio.dart';
import 'screens/home_screen.dart';
import 'screens/phase_screen.dart';

/// 路由表（平台契约：Studio 统一用 go_router）。
///
/// - `/`            阶段占位（加载中/失败/无数据）；数据就绪后经 `redirect`
///                  归一化到当前应展示的项目路径（`/` = 首个可用项目落地页）
/// - `/:wid/:pid`   项目看板：数据未就绪给阶段占位，就绪后装配 `ConsultCubit`
///                  并交棒 `ConsultBoardScreen`——看板装配内联在此，不设独立宿主组件
/// - 未知路径统一 `redirect` 回 `/`（`errorBuilder` 兜底）
///
/// 状态门通过 `redirect` + `refreshListenable` 实现；URL↔状态经 `reconcile`
/// 单点收敛：任一侧变化都用「当前 URI + 当前状态」重算一次，相等守卫保证终止。
/// [initialLocation] 非空时用 `overridePlatformDefaultLocation` 强制生效：
/// Web 构建里平台默认路由会退化成 `/`（深链冷启动会落到默认项目），
/// 生产入口（`app.dart` 的 `_webInitialLocation`）从 `Uri.base` 取浏览器地址传进来。
GoRouter buildRouter({String? initialLocation, required AppCubit appCubit}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    overridePlatformDefaultLocation: initialLocation != null,
    refreshListenable: _CubitRefresh(appCubit),
    redirect: (context, state) {
      final path = state.uri.path.isEmpty ? '/' : state.uri.path;
      final segments = state.uri.pathSegments;
      final known =
          path == '/' ||
          (segments.length == 2 && segments.every((s) => s.isNotEmpty));
      if (!known) return '/';

      if (path == '/') {
        final app = appCubit.state;
        if (app.status == AppStatus.success) {
          final workspaces = app.workspaces;
          if (workspaces == null ||
              workspaces.isEmpty ||
              workspaces.first.projectIds.isEmpty) {
            return null;
          }
          final target = projectLocation(
            workspaces.first.id,
            workspaces.first.projectIds.first,
          );
          return path == target ? null : target;
        }
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/:wid/:pid',
        builder: (context, state) => _projectRoute(context),
      ),
    ],
    errorBuilder: (context, state) => const HomeScreen(),
  );

  // URL ↔ 状态单向对齐：路由位置变化（站内 go、前进后退、深链）与状态变化
  // （加载完成、openProject 落地）都触发一次重算，只读「当前 URI」——
  // 收敛点全路由唯一，过渡期不存在两个读数不一致的实例。
  void reconcile() {
    final app = appCubit.state;
    if (app.status != AppStatus.success) return;
    final segments = router.routeInformationProvider.value.uri.pathSegments;
    if (segments.length != 2 || segments.any((s) => s.isEmpty)) return;
    if (app.currentWsId == segments[0] && app.currentProjectId == segments[1]) {
      return;
    }
    appCubit.openProject(segments[0], segments[1]);
  }

  router.routeInformationProvider.addListener(reconcile);
  appCubit.stream.listen((_) => reconcile());
  // 注册前可能已有 emit（如测试里 load 先于 buildRouter 完成），补算一次。
  reconcile();
  return router;
}

/// 工作区/项目看板的站内路径，路由构造统一走这里。
String projectLocation(String wid, String pid) => '/$wid/$pid';

/// `/:wid/:pid` 的渲染：未就绪给阶段占位，就绪后按当前项目装配看板。
Widget _projectRoute(BuildContext context) {
  return BlocBuilder<AppCubit, AppState>(
    builder: (context, app) {
      if (app.status != AppStatus.success) {
        return PhaseScreen(state: app);
      }
      final project = app.project!;
      final pid = app.currentProjectId ?? project.name;
      return BlocProvider<ConsultCubit>(
        key: ValueKey('${app.currentWsId}:$pid'),
        create: (_) => ConsultCubit(
          app.tasks!,
          app.cacheBuilder(app.currentWsId, pid),
          provider: app.provider,
          workspaceId: app.currentWsId,
          projectId: pid,
        ),
        child: ConsultBoardScreen(
          workspaces: app.workspaces,
          currentWsId: app.currentWsId,
          onSwitchWorkspace: app.workspaces == null
              ? null
              : (wid) {
                  final matches = app.workspaces!.where((w) => w.id == wid);
                  if (matches.isEmpty || matches.first.projectIds.isEmpty) {
                    return;
                  }
                  context.go(
                    projectLocation(wid, matches.first.projectIds.first),
                  );
                },
          loadWarning: app.loadWarning,
        ),
      );
    },
  );
}

/// [AppCubit] → [Listenable] 桥：bloc 是纯 Dart 包不能直接当
/// `refreshListenable`，订阅状态流、每次 emit 通知路由重算 `redirect`。
class _CubitRefresh extends ChangeNotifier {
  _CubitRefresh(AppCubit cubit) {
    cubit.stream.listen((_) => notifyListeners());
  }
}

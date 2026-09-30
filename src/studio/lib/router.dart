import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/project_screen.dart';
import 'states/app_cubit.dart';
import 'states/app_state.dart';

/// 路由表（平台契约：Studio 统一用 go_router）。
///
/// - `/`            阶段占位（加载中/失败/无数据）；数据就绪后经 `redirect`
///                  归一化到当前应展示的项目路径（`/` = 首个可用项目落地页）
/// - `/:wid/:pid`   项目看板宿主（深链与站内切换共用一条路径），冷启动数据
///                  未就绪时先渲染阶段占位
/// - 未知路径统一 `redirect` 回 `/`（`errorBuilder` 兜底）
///
/// 状态门通过 `redirect` + `refreshListenable` 实现：[AppCubit] 每次状态
/// 变化都触发重定向求值，视图层不再自行判断"该不该切页面"。
/// [initialLocation] 非空时用 `overridePlatformDefaultLocation` 强制生效：
/// Web 构建里平台默认路由会退化成 `/`（深链冷启动会落到默认项目），
/// 生产入口（`app.dart` 的 `_webInitialLocation`）从 `Uri.base` 取浏览器地址传进来。
GoRouter buildRouter({String? initialLocation, required AppCubit appCubit}) {
  return GoRouter(
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
        // 不加 const：路由参数变化靠新实例触 didUpdateWidget 跑 URL→状态同步
        builder: (context, state) => ProjectScreen(),
      ),
    ],
    errorBuilder: (context, state) => const HomeScreen(),
  );
}

/// 工作区/项目看板的站内路径，路由构造统一走这里。
String projectLocation(String wid, String pid) => '/$wid/$pid';

/// [AppCubit] → [Listenable] 桥：bloc 是纯 Dart 包不能直接当
/// `refreshListenable`，订阅状态流、每次 emit 通知路由重算 `redirect`。
class _CubitRefresh extends ChangeNotifier {
  _CubitRefresh(AppCubit cubit) {
    cubit.stream.listen((_) => notifyListeners());
  }
}

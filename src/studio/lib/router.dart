import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';

/// 路由表（平台契约：Studio 统一用 go_router）。
///
/// - `/`            默认入口：按数据加载状态渲染（首个可用项目）
/// - `/:wid/:pid`   工作区/项目深链，冷启动与站内切换共用一条路径
///
/// 三个入口统一渲染 [HomeScreen]，它自行读取 go_router 的当前 URI 决定
/// 打开哪个项目（URL 是唯一真相，过渡期新旧实例读数一致）。未知路径经
/// `errorBuilder` 回落首页（对齐 qtdata studio 的处理）。
/// [initialLocation] 非空时用 `overridePlatformDefaultLocation` 强制生效：
/// Web 构建里平台默认路由会退化成 `/`（深链冷启动会落到默认项目），
/// 生产入口（`app.dart` 的 `_webInitialLocation`）从 `Uri.base` 取浏览器地址传进来。
GoRouter buildRouter({String? initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation,
    overridePlatformDefaultLocation: initialLocation != null,
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/:wid/:pid',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    errorBuilder: (context, state) => const HomeScreen(),
  );
}

/// 工作区/项目看板的站内路径，路由构造统一走这里。
String projectLocation(String wid, String pid) => '/$wid/$pid';

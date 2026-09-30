import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'environment_config.dart';
import 'router.dart';
import 'services/provider_service.dart';
import 'states/app_cubit.dart';

/// 应用根组件：装配路由、环境配置、首页数据加载器与主题。
class QtConsultStudio extends StatelessWidget {
  /// 创建应用根组件。
  const QtConsultStudio({super.key});

  @override
  Widget build(BuildContext context) {
    final initialLocation = _webInitialLocation();
    final appCubit = AppCubit(
      provider: _providerFromConfig(),
      loadAsset: rootBundle.loadString,
      initialTarget: _routeTarget(initialLocation),
    )..load();
    final router = buildRouter(
      initialLocation: initialLocation,
      appCubit: appCubit,
    );
    return BlocProvider<AppCubit>(
      create: (_) => appCubit,
      child: MaterialApp.router(
        title: '量潮咨询',
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey,
            surface: Colors.white,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          useMaterial3: true,
        ),
      ),
    );
  }
}

ProviderService? _providerFromConfig() {
  final url = EnvironmentConfig.providerUrl;
  return url.isEmpty
      ? null
      : ProviderService(baseUrl: url, apiToken: EnvironmentConfig.apiToken);
}

/// Web 下把浏览器地址作为初始路由显式传给 go_router（`Uri.base` 是唯一可信源：
/// 平台默认路由在这个构建里会退化成 `/`，深链冷启动会落到默认项目）。
/// 非 Web（测试、桌面）返回 `null`，走平台默认。
String? _webInitialLocation() {
  if (!kIsWeb) return null;
  final u = Uri.base;
  final path = u.path.isEmpty ? '/' : u.path;
  return u.hasQuery ? '$path?${u.query}' : path;
}

/// 从初始路由解析 `/:wid/:pid` 深链目标；非两段路径返回 `null`。
({String wid, String pid})? _routeTarget(String? location) {
  if (location == null) return null;
  final segments = Uri.parse(location).pathSegments;
  if (segments.length != 2 || segments.any((s) => s.isEmpty)) return null;
  return (wid: segments[0], pid: segments[1]);
}

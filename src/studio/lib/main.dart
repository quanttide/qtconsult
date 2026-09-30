import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'environment_config.dart';
import 'screens/home_screen.dart';
import 'services/cache_service.dart';
import 'services/provider_service.dart';
import 'states/app_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(QtConsultStudio(provider: _providerFromConfig()));
}

ProviderService? _providerFromConfig() {
  final url = EnvironmentConfig.providerUrl;
  return url.isEmpty
      ? null
      : ProviderService(baseUrl: url, apiToken: EnvironmentConfig.apiToken);
}

CacheService _cacheFor(String wid, String pid) =>
    CacheService(filePath: 'data/cache/$wid/$pid.json');

/// 应用根组件：注入 provider 与首页数据加载器。
class QtConsultStudio extends StatelessWidget {
  /// 创建应用根组件；[provider] 为空时仅使用本地 fixture 数据源。
  const QtConsultStudio({super.key, required this.provider});

  /// 远端 provider 服务。
  final ProviderService? provider;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppCubit>(
      create: (_) => AppCubit(
        provider: provider,
        cacheBuilder: _cacheFor,
        loadAsset: rootBundle.loadString,
      )..load(),
      child: MaterialApp(
        title: '量潮咨询',
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
        home: const HomeScreen(),
      ),
    );
  }
}

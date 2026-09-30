import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'environment_config.dart';
import 'screens/home_screen.dart';
import 'services/provider_service.dart';
import 'states/app_cubit.dart';

/// 应用根组件：装配环境配置、首页数据加载器与主题。
class QtConsultStudio extends StatelessWidget {
  /// 创建应用根组件。
  const QtConsultStudio({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppCubit>(
      create: (_) => AppCubit(
        provider: _providerFromConfig(),
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

ProviderService? _providerFromConfig() {
  final url = EnvironmentConfig.providerUrl;
  return url.isEmpty
      ? null
      : ProviderService(baseUrl: url, apiToken: EnvironmentConfig.apiToken);
}

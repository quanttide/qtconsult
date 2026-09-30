import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../qtconsult_studio.dart';
import 'phase_screen.dart';

/// `/` 首页：只渲染数据未就绪的阶段占位。
///
/// 数据就绪后由路由表的 `redirect`（经 `refreshListenable` 触发）把 `/`
/// 归一化到具体项目路径 `/:wid/:pid`，看板由 `ProjectScreen` 承接——
/// 本组件不接触看板，`success` 单帧渲染占位等待 redirect 接管。
class HomeScreen extends StatelessWidget {
  /// 创建首页。
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) => PhaseScreen(state: state),
    );
  }
}

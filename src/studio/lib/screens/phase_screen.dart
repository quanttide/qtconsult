import 'package:flutter/material.dart';

import '../qtconsult_studio.dart';

/// 数据未就绪阶段的占位屏：加载中 / 加载失败 / 无可用数据。
///
/// 供 `HomeScreen`（`/`）与 `ProjectScreen`（`/:wid/:pid` 冷启动期）共用。
/// `success` 分支渲染加载占位——正常流程下它会被路由 `redirect` 抢先接管，
/// 仅作单帧防御，看板不在这里出现。
class PhaseScreen extends StatelessWidget {
  /// 创建阶段占位屏。
  const PhaseScreen({super.key, required this.state});

  /// 当前应用数据状态。
  final AppState state;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case AppStatus.failure:
        return const Scaffold(
          body: Center(
            child: Text('加载失败', style: TextStyle(color: Colors.red)),
          ),
        );
      case AppStatus.noData:
        return const Scaffold(
          body: Center(
            child: Text('无可用的项目数据', style: TextStyle(color: Colors.red)),
          ),
        );
      case AppStatus.loading:
      case AppStatus.success:
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
  }
}

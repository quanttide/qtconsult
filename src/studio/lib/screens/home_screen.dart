import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../qtconsult_studio.dart';

/// 首页：按加载阶段渲染加载中、失败、无数据或看板主体。
class HomeScreen extends StatelessWidget {
  /// 创建首页。
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        switch (state.status) {
          case AppStatus.loading:
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      '正在加载数据……',
                      style: TextStyle(color: Color(0xFF999999)),
                    ),
                  ],
                ),
              ),
            );
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
          case AppStatus.success:
            return _BoardHost(state: state);
        }
      },
    );
  }
}

class _BoardHost extends StatelessWidget {
  const _BoardHost({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final project = state.project!;
    final tasks = state.tasks!;
    final pid = state.currentProjectId ?? project.name;
    return BlocProvider<ConsultCubit>(
      key: ValueKey('${state.currentWsId}:$pid'),
      create: (_) => ConsultCubit(
        tasks,
        state.cacheBuilder(state.currentWsId, pid),
        provider: state.provider,
        workspaceId: state.currentWsId,
        projectId: pid,
      ),
      child: ConsultBoardScreen(
        workspaces: state.workspaces,
        currentWsId: state.currentWsId,
        onSwitchWorkspace: state.workspaces == null
            ? null
            : (wid) => context.read<AppCubit>().switchWorkspace(wid),
        loadWarning: state.loadWarning,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../qtconsult_studio.dart';
import '../router.dart';

/// 首页：按加载阶段渲染加载中、失败、无数据或看板主体。
///
/// 路由与 [AppCubit] 状态单向对齐：同步时直接读取 go_router 的**当前**
/// 位置（不读 widget 参数），站内 `go`、浏览器前进后退、深链、过渡期
/// 新旧实例读数必然一致，不会互相拉扯。URL 是「打开哪个项目」的唯一真相。
class HomeScreen extends StatefulWidget {
  /// 创建首页。
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncRouteToCubit('didChangeDependencies');
  }

  @override
  void didUpdateWidget(covariant HomeScreen old) {
    super.didUpdateWidget(old);
    _syncRouteToCubit('didUpdateWidget');
  }

  void _syncRouteToCubit(String source) {
    if (!mounted) return;
    final router = GoRouter.maybeOf(context);
    if (router == null) return;
    final cubit = context.read<AppCubit>();
    final current = cubit.state;
    if (current.status != AppStatus.success) return;

    // 读原始路由信息而非 router.state：未匹配路径（errorBuilder 场景）下
    // state 会因空 match list 抛 `Bad state: No element`。
    final segments = router.routeInformationProvider.value.uri.pathSegments;
    String? targetWid;
    String? targetPid;
    if (segments.length == 2 && segments.every((s) => s.isNotEmpty)) {
      targetWid = segments[0];
      targetPid = segments[1];
    } else {
      final workspaces = current.workspaces;
      if (workspaces == null ||
          workspaces.isEmpty ||
          workspaces.first.projectIds.isEmpty) {
        return;
      }
      targetWid = workspaces.first.id;
      targetPid = workspaces.first.projectIds.first;
    }
    if (current.currentWsId == targetWid &&
        current.currentProjectId == targetPid) {
      return;
    }
    cubit.openProject(targetWid, targetPid);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppCubit, AppState>(
      listener: (context, state) => _syncRouteToCubit('listener'),
      child: BlocBuilder<AppCubit, AppState>(
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
      ),
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
            : (wid) {
                final matches = state.workspaces!.where((w) => w.id == wid);
                if (matches.isEmpty || matches.first.projectIds.isEmpty) {
                  return;
                }
                context.go(
                  projectLocation(wid, matches.first.projectIds.first),
                );
              },
        loadWarning: state.loadWarning,
      ),
    );
  }
}

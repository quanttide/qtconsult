import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../qtconsult_studio.dart';
import '../router.dart';
import 'phase_placeholder.dart';

/// `/:wid/:pid` 看板宿主：URL 与 [AppCubit] 状态单向对齐并渲染看板。
///
/// 同步只读取 go_router 的**当前** URI（不读任何 widget 参数），站内 `go`、
/// 浏览器前进后退、深链、过渡期新旧实例读数必然一致，不会互相拉扯——
/// URL 是「打开哪个项目」的唯一真相。冷启动深链在数据就绪前渲染
/// [PhasePlaceholder]；站内切换工作区由看板 AppBar 回调 `context.go` 改写 URL。
class ProjectScreen extends StatefulWidget {
  /// 创建看板宿主。
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncRouteToCubit();
  }

  @override
  void didUpdateWidget(covariant ProjectScreen old) {
    super.didUpdateWidget(old);
    _syncRouteToCubit();
  }

  void _syncRouteToCubit() {
    if (!mounted) return;
    final router = GoRouter.maybeOf(context);
    if (router == null) return;
    final cubit = context.read<AppCubit>();
    final current = cubit.state;
    if (current.status != AppStatus.success) return;

    // 读原始路由信息而非 router.state：未匹配路径下 state 会因空 match list
    // 抛 `Bad state: No element`。
    final segments = router.routeInformationProvider.value.uri.pathSegments;
    if (segments.length != 2 || segments.any((s) => s.isEmpty)) return;
    final targetWid = segments[0];
    final targetPid = segments[1];
    if (current.currentWsId == targetWid &&
        current.currentProjectId == targetPid) {
      return;
    }
    cubit.openProject(targetWid, targetPid);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppCubit, AppState>(
      listener: (context, state) => _syncRouteToCubit(),
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          if (state.status != AppStatus.success) {
            return PhasePlaceholder(state: state);
          }
          return _BoardHost(state: state);
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

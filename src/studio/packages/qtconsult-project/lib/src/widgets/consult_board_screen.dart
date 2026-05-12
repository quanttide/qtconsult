import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_sources/provider_service.dart';
import 'package:qtconsult_project/qtconsult_project.dart';
import 'package:flutter_quanttide_project/flutter_quanttide_project.dart' as ui;
import 'workspace_switcher.dart';
import 'stage_column.dart';
import 'simple_card.dart';

class ConsultBoardScreen extends StatelessWidget {
  final List<WorkspaceInfo>? workspaces;
  final String? currentWsId;
  final void Function(String wid)? onSwitchWorkspace;
  final String? loadWarning;

  const ConsultBoardScreen({
    super.key,
    this.workspaces,
    this.currentWsId,
    this.onSwitchWorkspace,
    this.loadWarning,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('量潮咨询'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        actions: [
          if (workspaces != null && currentWsId != null && onSwitchWorkspace != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: WorkspaceSwitcher(
                workspaces: workspaces!,
                currentWsId: currentWsId!,
                onSwitch: onSwitchWorkspace!,
              ),
            ),
        ],
      ),
      body: Consumer<ConsultState>(
        builder: (context, state, _) {
          final lists = state.lists;
          return Column(
            children: [
              if (loadWarning != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: const Color(0xFFFFF8E1),
                  child: Text(
                    loadWarning!,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8A5A00)),
                  ),
                ),
              Expanded(
                child: ui.BoardView(
                  header: _buildHeader(),
                  columns: [
                    (child: StageColumn(
                      title: BoardColumnTitle(
                        icon: Icons.search_outlined,
                        title: '需求澄清 · Clarify',
                        count: '${lists.clarify.length} 项',
                      ),
                      content: ListView(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
                        children: lists.clarify.map((t) => SimpleCard(task: t)).toList(),
                      ),
                    ), flex: 1.0),
                    (child: StageColumn(
                      title: BoardColumnTitle(
                        icon: Icons.psychology_outlined,
                        title: '调研分析 · Research',
                        count: '${lists.research.length} 条',
                      ),
                      content: ListView(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
                        children: lists.research.map((t) => SimpleCard(task: t)).toList(),
                      ),
                    ), flex: 1.0),
                    (child: StageColumn(
                      title: BoardColumnTitle(
                        icon: Icons.account_tree_outlined,
                        title: '决策方案 · Decide',
                        count: '${lists.decide.length} 套方案',
                      ),
                      content: ListView(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
                        children: lists.decide.map((t) => SimpleCard(task: t)).toList(),
                      ),
                    ), flex: 1.0),
                    (child: StageColumn(
                      title: BoardColumnTitle(
                        icon: Icons.play_arrow_outlined,
                        title: '执行跟踪 · Execute',
                        count: '${lists.execute.length} 项任务',
                      ),
                      content: ListView(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
                        children: lists.execute.map((t) => SimpleCard(task: t)).toList(),
                      ),
                    ), flex: 0.7),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF444444),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '咨询看板',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF222222)),
          ),
          const Spacer(),
          _buildLegend('需求澄清 · Clarify', const Color(0xFF444444)),
          const SizedBox(width: 14),
          _buildLegend('调研分析 · Research', const Color(0xFF666666)),
          const SizedBox(width: 14),
          _buildLegend('决策方案 · Decide', const Color(0xFF888888)),
          const SizedBox(width: 14),
          _buildLegend('执行跟踪 · Execute', const Color(0xFFAAAAAA)),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
      ],
    );
  }
}

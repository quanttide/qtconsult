import 'package:flutter/material.dart';
import 'package:data_sources/provider_service.dart';
import 'board_view.dart';
import 'workspace_switcher.dart';
import 'observe_column.dart';
import 'orient_column.dart';
import 'decide_column.dart';
import 'act_column.dart';

class OodaScreen extends StatelessWidget {
  final List<WorkspaceInfo>? workspaces;
  final String? currentWsId;
  final void Function(String wid)? onSwitchWorkspace;
  final String? loadWarning;

  const OodaScreen({
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
        title: const Text('量潮咨询服务看板'),
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
      body: Column(
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
            child: BoardView(
              header: _buildHeader(),
              columns: const [
                ObserveColumn(),
                OrientColumn(),
                DecideColumn(),
                ActColumn(),
              ],
              flexes: [1.3, 1.0, 1.0, 0.7],
            ),
          ),
        ],
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
            '咨询服务看板',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF222222)),
          ),
          const Spacer(),
          _buildLegend('调研 · Observe', const Color(0xFF444444)),
          const SizedBox(width: 14),
          _buildLegend('分析 · Orient', const Color(0xFF666666)),
          const SizedBox(width: 14),
          _buildLegend('决策 · Decide', const Color(0xFF888888)),
          const SizedBox(width: 14),
          _buildLegend('执行 · Act', const Color(0xFFAAAAAA)),
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

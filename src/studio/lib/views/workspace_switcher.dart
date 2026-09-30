import 'package:flutter/material.dart';
import '../services/provider_service.dart';

/// 工作区切换器：AppBar 中的下拉菜单，列出并切换其他工作区。
class WorkspaceSwitcher extends StatelessWidget {
  /// 全部可选工作区。
  final List<WorkspaceInfo> workspaces;

  /// 当前工作区 id，不在下拉列表中重复展示。
  final String currentWsId;

  /// 选中工作区时的回调，参数为目标工作区 id。
  final ValueChanged<String> onSwitch;

  /// 创建工作区切换器。
  const WorkspaceSwitcher({
    super.key,
    required this.workspaces,
    required this.currentWsId,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: currentWsId,
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspaces_outlined, size: 18),
          const SizedBox(width: 4),
          Text(
            workspaces.firstWhere((w) => w.id == currentWsId).name,
            style: const TextStyle(fontSize: 14),
          ),
          const Icon(Icons.arrow_drop_down, size: 18),
        ],
      ),
      onSelected: onSwitch,
      itemBuilder: (context) => workspaces
          .where((w) => w.id != currentWsId)
          .map((w) => PopupMenuItem(value: w.id, child: Text(w.name)))
          .toList(),
    );
  }
}

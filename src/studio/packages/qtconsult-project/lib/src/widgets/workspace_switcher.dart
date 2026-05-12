import 'package:flutter/material.dart';
import 'package:data_sources/provider_service.dart';

class WorkspaceSwitcher extends StatelessWidget {
  final List<WorkspaceInfo> workspaces;
  final String currentWsId;
  final ValueChanged<String> onSwitch;

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
          .map((w) => PopupMenuItem(
                value: w.id,
                child: Text(w.name),
              ))
          .toList(),
    );
  }
}

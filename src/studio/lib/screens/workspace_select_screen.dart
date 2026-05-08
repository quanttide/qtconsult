import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qtconsult_studio/screens/ooda_screen.dart';
import 'package:qtconsult_studio/services/cache_service.dart';
import 'package:qtconsult_studio/services/ooda_state.dart';
import 'package:qtconsult_studio/services/provider_service.dart';

class WorkspaceSelectScreen extends StatelessWidget {
  final List<WorkspaceInfo> workspaces;
  final CacheService Function(String wid, String pid) cacheBuilder;
  final ProviderService? provider;

  const WorkspaceSelectScreen({
    super.key,
    required this.workspaces,
    required this.cacheBuilder,
    this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('量潮咨询服务看板'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              '选择工作区',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          for (final ws in workspaces)
            _WorkspaceCard(
              workspace: ws,
              onProjectTap: (pid) => _openProject(context, ws.id, pid),
            ),
        ],
      ),
    );
  }

  void _openProject(BuildContext context, String wid, String pid) {
    final cache = cacheBuilder(wid, pid);
    provider?.loadProject(wid, pid).then((p) => cache.save(p)).catchError((_) {});
    cache.load().then((project) {
      if (project == null || !context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => OodaState(project, cache, provider: provider, workspaceId: wid, projectId: pid),
            child: const OodaScreen(),
          ),
        ),
      );
    });
  }
}

class _WorkspaceCard extends StatefulWidget {
  final WorkspaceInfo workspace;
  final void Function(String projectId) onProjectTap;

  const _WorkspaceCard({required this.workspace, required this.onProjectTap});

  @override
  State<_WorkspaceCard> createState() => _WorkspaceCardState();
}

class _WorkspaceCardState extends State<_WorkspaceCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ws = widget.workspace;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            title: Text(ws.name, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('${ws.projectIds.length} 个项目'),
            trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            ...ws.projectIds.map((pid) => ListTile(
              leading: const Icon(Icons.folder_open, size: 20),
              title: Text(pid),
              onTap: () => widget.onProjectTap(pid),
            )),
        ],
      ),
    );
  }
}

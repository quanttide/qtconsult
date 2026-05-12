import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_sources/provider_service.dart';
import 'package:qtconsult_project/qtconsult_project.dart';
import 'package:flutter_quanttide_project/flutter_quanttide_project.dart' as ui;
import 'workspace_switcher.dart';
import 'stage_column.dart';

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
      body: Consumer<OodaState>(
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
                        title: '调研 · Observe',
                        count: '${lists.ideals.length + lists.realities.length} 条',
                      ),
                      content: _ObserveBody(ideals: lists.ideals, realities: lists.realities),
                    ), flex: 1.3),
                    (child: StageColumn(
                      title: BoardColumnTitle(
                        icon: Icons.psychology_outlined,
                        title: '分析 · Orient',
                        count: '${lists.clusters.fold(0, (sum, c) => sum + c.tasks.length)} 条洞察',
                      ),
                      content: _OrientContent(clusters: lists.clusters),
                    ), flex: 1.0),
                    (child: StageColumn(
                      title: BoardColumnTitle(
                        icon: Icons.account_tree_outlined,
                        title: '决策 · Decide',
                        count: '${lists.decide.length} 套方案',
                      ),
                      content: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                        children: lists.decide.map((t) => _DecideCard(task: t)).toList(),
                      ),
                    ), flex: 1.0),
                    (child: StageColumn(
                      title: BoardColumnTitle(
                        icon: Icons.play_arrow_outlined,
                        title: '执行 · Act',
                        count: '${lists.act.length} 项任务',
                      ),
                      content: ListView(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
                        children: lists.act.map((t) => _ActCard(task: t)).toList(),
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

// --- Observe ---

class _ObserveBody extends StatelessWidget {
  final List<Task> ideals;
  final List<Task> realities;

  const _ObserveBody({required this.ideals, required this.realities});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _side('业务理想', ideals, Colors.white),
          const SizedBox(width: 8),
          _side('现实状况', realities, const Color(0xFFFAFAFA)),
        ],
      ),
    );
  }

  Widget _side(String label, List<Task> tasks, Color bgColor) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              width: double.infinity,
              child: Row(
                children: [
                  Text(label,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF666666))),
                  const SizedBox(width: 4),
                  Text('${tasks.length}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                children: tasks.map<Widget>((t) => _ObserveCard(task: t)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObserveCard extends StatelessWidget {
  final Task task;

  const _ObserveCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final state = context.read<OodaState>();
    final isConfirmed = task.status == 'confirmed';
    return ui.BoardCard(
      title: Row(
        children: [
          Expanded(child: BoardCardTitle(text: task.title)),
          GestureDetector(
            onTap: () => state.toggleObserveConfirm(task.id),
            child: Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isConfirmed ? const Color(0xFF333333) : const Color(0xFFCCCCCC),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
                color: isConfirmed ? const Color(0xFF333333) : Colors.transparent,
              ),
              child: isConfirmed
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
      description: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoardCardDescription(text: task.description),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(task.tags['source'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isConfirmed ? const Color(0xFFF2F2F2) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isConfirmed ? '已确认' : '待确认',
                  style: TextStyle(fontSize: 11,
                      color: isConfirmed ? const Color(0xFF1A1A1A) : const Color(0xFF888888)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Orient ---

class _OrientContent extends StatefulWidget {
  final List<TaskCluster> clusters;

  const _OrientContent({required this.clusters});

  @override
  State<_OrientContent> createState() => _OrientContentState();
}

class _OrientContentState extends State<_OrientContent> {
  final Set<String> _collapsed = {};
  String _filter = '全部';

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == '全部'
        ? widget.clusters
        : widget.clusters.where((c) => c.name == _filter).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      children: [
        _buildFilters(),
        const SizedBox(height: 6),
        ...filtered.map((c) => _buildCluster(c)),
      ],
    );
  }

  Widget _buildFilters() {
    final names = ['全部', ...widget.clusters.map((c) => c.name)];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: names.map((name) {
          final isActive = name == _filter;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () => setState(() => _filter = name),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF444444) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive ? const Color(0xFF444444) : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Text(name,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        color: isActive ? Colors.white : const Color(0xFF888888))),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCluster(TaskCluster cluster) {
    final isCollapsed = _collapsed.contains(cluster.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() {
            if (isCollapsed) _collapsed.remove(cluster.name);
            else _collapsed.add(cluster.name);
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(isCollapsed ? '▸' : '▾',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF999999))),
                const SizedBox(width: 6),
                Text(cluster.name,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF666666))),
                const SizedBox(width: 6),
                Text('${cluster.tasks.length}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
              ],
            ),
          ),
        ),
        if (!isCollapsed) ...cluster.tasks.map((t) => _OrientInsight(task: t)),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _OrientInsight extends StatelessWidget {
  final Task task;

  const _OrientInsight({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E6E6)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A1A))),
          if (task.tags['rootCause'] != null) ...[
            const SizedBox(height: 8),
            Text('根因：${task.tags['rootCause']}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.6)),
          ],
          if (task.tags['impact'] != null) ...[
            const SizedBox(height: 4),
            Text('影响：${task.tags['impact']}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.6)),
          ],
        ],
      ),
    );
  }
}

// --- Decide ---

class _DecideCard extends StatelessWidget {
  final Task task;

  const _DecideCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final state = context.read<OodaState>();
    final isSelected = task.tags['isSelected'] == 'true';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFFE6E6E6),
          width: isSelected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? const Color(0xFFFAFAFA) : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(task.title,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1A1A1A))),
                    ),
                    if ((task.priority)?.isNotEmpty == true) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(task.priority!,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ],
                ),
              ),
              Text('关联 ${task.upstream.length} 条洞察',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
            ],
          ),
          const SizedBox(height: 10),
          _row('优势', task.tags['advantage'] ?? ''),
          const SizedBox(height: 6),
          _row('概要', task.tags['summary'] ?? ''),
          const SizedBox(height: 6),
          _row('资源与价格', task.tags['resources'] ?? ''),
          if ((task.tags['keyAssumption'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('关键假设：${task.tags['keyAssumption']}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999), fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE6E6E6)),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => state.toggleStrategySelect(task.id),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? const Color(0xFF333333) : const Color(0xFFCCCCCC),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        color: isSelected ? const Color(0xFF333333) : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 6),
                    const Text('倾向本方案',
                        style: TextStyle(fontSize: 13, color: Color(0xFF1A1A1A))),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: TextField(
                    controller: TextEditingController(text: task.tags['clientNote'] ?? ''),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                    decoration: InputDecoration(
                      hintText: '填写顾虑或条件……',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFCCCCCC)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      isDense: true,
                    ),
                    onChanged: (v) => state.updateClientNote(task.id, v),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String text) {
    return Text.rich(TextSpan(
      children: [
        TextSpan(text: '$label：',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
        TextSpan(text: text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.6)),
      ],
    ));
  }
}

// --- Act ---

class _ActCard extends StatelessWidget {
  final Task task;

  const _ActCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final status = task.status;
    final progressStr = task.tags['progress'] ?? '0';
    final progress = double.tryParse(progressStr) ?? 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: status == 'doing' ? const Color(0xFF999999)
              : status == 'done' ? const Color(0xFF444444)
              : status == 'blocked' ? const Color(0xFFCCCCCC)
              : const Color(0xFFE0E0E0),
          width: status == 'doing' ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: status == 'done' ? const Color(0xFFFAFAFA)
            : status == 'blocked' ? const Color(0xFFF5F5F5)
            : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(task.title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14,
                        color: status == 'done' ? const Color(0xFF888888) : const Color(0xFF1A1A1A))),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusBgColor(status),
                  borderRadius: BorderRadius.circular(10),
                  border: status == 'blocked' ? Border.all(color: const Color(0xFFCCCCCC)) : null,
                ),
                child: Text(taskStatusLabel(status),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: taskStatusColor(status))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if ((task.tags['linkedStrategy'] ?? '').isNotEmpty)
            _metaRow('关联', task.tags['linkedStrategy']!),
          if (task.assignee != null && task.assignee!.isNotEmpty)
            _metaRow('负责人', task.assignee!),
          if (task.startAt != null)
            _metaRow('计划', '${task.startAt} → ${task.endAt}'),
          if ((task.tags['notes'] ?? '').isNotEmpty)
            _metaRow('备注', task.tags['notes']!),
          if (status == 'blocked' && (task.tags['blockedReason'] ?? '').isNotEmpty)
            _metaRow('受阻原因', task.tags['blockedReason']!),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: const Color(0xFFE6E6E6),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF333333)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text.rich(TextSpan(
        children: [
          TextSpan(text: '$label：', style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
          TextSpan(text: value, style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
        ],
      )),
    );
  }

  Color _statusBgColor(String? status) {
    switch (status) {
      case 'todo': return const Color(0xFFF5F5F5);
      case 'doing': return const Color(0xFFEEEEEE);
      case 'done': return const Color(0xFFF0F0F0);
      case 'blocked': return const Color(0xFFF5F5F5);
      default: return const Color(0xFFF5F5F5);
    }
  }
}

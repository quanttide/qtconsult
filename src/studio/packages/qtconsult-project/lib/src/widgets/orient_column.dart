import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qtconsult_project/qtconsult_project.dart';

class OrientColumn extends StatelessWidget {
  const OrientColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OodaState>(
      builder: (context, state, _) {
        return _ColumnLayout(clusters: state.project.lists.clusters);
      },
    );
  }
}

class _ColumnLayout extends StatefulWidget {
  final List<BoardCardCluster> clusters;

  const _ColumnLayout({required this.clusters});

  @override
  State<_ColumnLayout> createState() => _ColumnLayoutState();
}

class _ColumnLayoutState extends State<_ColumnLayout> {
  final Set<String> _collapsed = {};
  String _filter = '全部';

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == '全部'
        ? widget.clusters
        : widget.clusters.where((c) => c.name == _filter).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              children: [
                _buildFilters(),
                const SizedBox(height: 6),
                ...filtered.map((c) => _buildCluster(c)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    final total = widget.clusters.fold(0, (sum, c) => sum + c.cards.length);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE6E6E6))),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology_outlined, size: 16, color: Color(0xFF333333)),
          const SizedBox(width: 8),
          const Text('分析 · Orient',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
          const Spacer(),
          Text('$total 条洞察',
              style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
        ],
      ),
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

  Widget _buildCluster(BoardCardCluster cluster) {
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
                Text('${cluster.cards.length}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
              ],
            ),
          ),
        ),
        if (!isCollapsed) ...cluster.cards.map((c) => _InsightCardWidget(card: c)),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _InsightCardWidget extends StatelessWidget {
  final BoardCard card;

  const _InsightCardWidget({required this.card});

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
          Text(card.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A1A))),
          if (card.custom['rootCause'] != null) ...[
            const SizedBox(height: 8),
            Text('根因：${card.custom['rootCause']}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.6)),
          ],
          if (card.custom['impact'] != null) ...[
            const SizedBox(height: 4),
            Text('影响：${card.custom['impact']}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.6)),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qtconsult_studio/models/ooda_data.dart';
import 'package:qtconsult_studio/services/ooda_state.dart';

class OrientColumn extends StatelessWidget {
  const OrientColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OodaState>(
      builder: (context, state, _) {
        final clusters = state.data.clusters;
        return _ColumnLayout(clusters: clusters);
      },
    );
  }
}

class _ColumnLayout extends StatefulWidget {
  final List<InsightCluster> clusters;

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
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology_outlined, size: 14, color: Color(0xFF444444)),
          const SizedBox(width: 6),
          const Text(
            '分析 · Orient',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),
          const Spacer(),
          Text(
            '${widget.clusters.fold(0, (sum, c) => sum + c.insights.length)} 条洞察',
            style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA)),
          ),
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
                  color:
                      isActive ? const Color(0xFF444444) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF444444)
                        : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? Colors.white : const Color(0xFF888888),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCluster(InsightCluster cluster) {
    final isCollapsed = _collapsed.contains(cluster.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              if (isCollapsed) {
                _collapsed.remove(cluster.name);
              } else {
                _collapsed.add(cluster.name);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Text(
                  isCollapsed ? '▸' : '▾',
                  style: const TextStyle(fontSize: 8, color: Color(0xFFAAAAAA)),
                ),
                const SizedBox(width: 4),
                Text(
                  cluster.name,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF777777),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${cluster.insights.length}',
                  style: const TextStyle(fontSize: 9, color: Color(0xFFAAAAAA)),
                ),
              ],
            ),
          ),
        ),
        if (!isCollapsed)
          ...cluster.insights.map((insight) => _InsightCardWidget(insight: insight)),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _InsightCardWidget extends StatelessWidget {
  final InsightCard insight;

  const _InsightCardWidget({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            insight.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 3,
            runSpacing: 2,
            children: insight.evidences.map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  e.label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF888888),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          Text(
            '根因：${insight.rootCause}',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF777777),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '影响：${insight.impact}',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF777777),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

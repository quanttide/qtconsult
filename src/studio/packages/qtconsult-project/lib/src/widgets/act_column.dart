import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qtconsult_project/qtconsult_project.dart';
import 'board_column.dart';
import 'board_column_title.dart';

class ActColumn extends StatelessWidget {
  const ActColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OodaState>(
      builder: (context, state, _) {
        final tasks = state.project.lists.act;
        return BoardColumn(
          title: BoardColumnTitle(
            icon: Icons.play_arrow_outlined,
            title: '执行 · Act',
            count: '${tasks.length} 项任务',
          ),
          content: ListView(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
            children: tasks.map<Widget>((t) => _TaskCardWidget(card: t)).toList(),
          ),
        );
      },
    );
  }
}

class _TaskCardWidget extends StatelessWidget {
  final BoardCard card;

  const _TaskCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    final status = card.custom['status'] as String?;
    final progress = (card.custom['progress'] as num?)?.toDouble() ?? 0.0;
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
                child: Text(card.title,
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
          if ((card.custom['linkedStrategy'] as String?)?.isNotEmpty == true)
            _metaRow('关联', card.custom['linkedStrategy'] as String),
          if (card.assignee != null && card.assignee!.isNotEmpty)
            _metaRow('负责人', card.assignee!),
          if (card.date is Map && (card.date['start'] as String?)?.isNotEmpty == true)
            _metaRow('计划', '${card.date['start']} → ${card.date['end']}'),
          if ((card.custom['notes'] as String?)?.isNotEmpty == true)
            _metaRow('备注', card.custom['notes'] as String),
          if (status == 'blocked' && (card.custom['blockedReason'] as String?)?.isNotEmpty == true)
            _metaRow('受阻原因', card.custom['blockedReason'] as String),
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

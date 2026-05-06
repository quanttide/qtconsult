import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qtconsult_studio/models/ooda_data.dart';
import 'package:qtconsult_studio/services/ooda_state.dart';

class ActColumn extends StatelessWidget {
  const ActColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OodaState>(
      builder: (context, state, _) {
        return _ColumnLayout(tasks: state.data.tasks);
      },
    );
  }
}

class _ColumnLayout extends StatelessWidget {
  final List<TaskCard> tasks;

  const _ColumnLayout({required this.tasks});

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
                children: tasks.map((t) => _TaskCardWidget(task: t)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE6E6E6))),
      ),
      child: const Row(
        children: [
          Icon(Icons.play_arrow_outlined, size: 16, color: Color(0xFF333333)),
          SizedBox(width: 8),
          Text(
            '执行 · Act',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          Spacer(),
          Text(
            '6 项任务',
            style: TextStyle(fontSize: 11, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }
}

class _TaskCardWidget extends StatelessWidget {
  final TaskCard task;

  const _TaskCardWidget({required this.task});

  @override
  Widget build(BuildContext context) {
    final bgColor = task.status == TaskStatus.done
        ? const Color(0xFFFAFAFA)
        : task.status == TaskStatus.blocked
            ? const Color(0xFFF5F5F5)
            : Colors.white;

    final borderColor = task.status == TaskStatus.doing
        ? const Color(0xFF999999)
        : task.status == TaskStatus.done
            ? const Color(0xFF444444)
            : task.status == TaskStatus.blocked
                ? const Color(0xFFCCCCCC)
                : const Color(0xFFE0E0E0);



    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: task.status == TaskStatus.doing ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: bgColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  task.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: task.status == TaskStatus.done
                        ? const Color(0xFF888888)
                        : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusBgColor(task.status),
                  borderRadius: BorderRadius.circular(10),
                  border: task.status == TaskStatus.blocked
                      ? Border.all(
                          color: const Color(0xFFCCCCCC),
                          style: BorderStyle.solid,
                        )
                      : null,
                ),
                child: Text(
                  taskStatusLabel(task.status),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: taskStatusColor(task.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (task.linkedStrategy.isNotEmpty)
            _metaRow('关联', task.linkedStrategy),
          if (task.assignee.isNotEmpty) _metaRow('负责人', task.assignee),
          if (task.startDate.isNotEmpty && task.endDate.isNotEmpty)
            _metaRow('计划', '${task.startDate} → ${task.endDate}'),
          if (task.notes.isNotEmpty) _metaRow('备注', task.notes),
          if (task.status == TaskStatus.blocked && task.blockedReason.isNotEmpty)
            _metaRow('受阻原因', task.blockedReason),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: task.progress,
              minHeight: 4,
              backgroundColor: const Color(0xFFE6E6E6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label：',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF999999),
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusBgColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return const Color(0xFFF5F5F5);
      case TaskStatus.doing:
        return const Color(0xFFEEEEEE);
      case TaskStatus.done:
        return const Color(0xFFF0F0F0);
      case TaskStatus.blocked:
        return const Color(0xFFF5F5F5);
    }
  }
}

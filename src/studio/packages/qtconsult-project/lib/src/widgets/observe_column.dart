import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qtconsult_project/qtconsult_project.dart';
import 'board_column.dart';
import 'board_column_title.dart';

class ObserveColumn extends StatelessWidget {
  const ObserveColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OodaState>(
      builder: (context, state, _) {
        final lists = state.project.lists;
        return BoardColumn(
          title: BoardColumnTitle(
            icon: Icons.search_outlined,
            title: '调研 · Observe',
            count: '${lists.ideals.length + lists.realities.length} 条',
          ),
          content: _Body(ideals: lists.ideals, realities: lists.realities),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  final List<BoardCard> ideals;
  final List<BoardCard> realities;

  const _Body({required this.ideals, required this.realities});

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

  Widget _side(String label, List<BoardCard> cards, Color bgColor) {
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
                  Text('${cards.length}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                children: cards.map<Widget>((c) => _CardWidget(card: c)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardWidget extends StatelessWidget {
  final BoardCard card;

  const _CardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    final state = context.read<OodaState>();
    final status = card.custom['status'] as String?;
    final isConfirmed = status == 'confirmed';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isConfirmed ? const Color(0xFF444444) : const Color(0xFFCCCCCC),
            width: 4,
          ),
        ),
        color: isConfirmed ? const Color(0xFFFAFAFA) : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(card.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A1A))),
              ),
              GestureDetector(
                onTap: () => state.toggleObserveConfirm(card.id),
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
          const SizedBox(height: 6),
          Text(card.description,
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.6),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(card.custom['source'] as String? ?? '',
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

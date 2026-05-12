import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qtconsult_project/qtconsult_project.dart';

class DecideColumn extends StatelessWidget {
  const DecideColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OodaState>(
      builder: (context, state, _) {
        return _ColumnLayout(strategies: state.project.lists.decide);
      },
    );
  }
}

class _ColumnLayout extends StatelessWidget {
  final List<BoardCard> strategies;

  const _ColumnLayout({required this.strategies});

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
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              children: strategies.map<Widget>((s) => _StrategyCardWidget(card: s)).toList(),
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
          Icon(Icons.account_tree_outlined, size: 16, color: Color(0xFF333333)),
          SizedBox(width: 8),
          Text('决策 · Decide',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
          Spacer(),
          Text('2 套方案', style: TextStyle(fontSize: 11, color: Color(0xFF999999))),
        ],
      ),
    );
  }
}

class _StrategyCardWidget extends StatelessWidget {
  final BoardCard card;

  const _StrategyCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    final state = context.read<OodaState>();
    final isSelected = card.custom['isSelected'] == true;
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
                      child: Text(card.title,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1A1A1A))),
                    ),
                    if ((card.custom['priority'] as String?)?.isNotEmpty == true) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(card.custom['priority'] as String,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ],
                ),
              ),
              Text('关联 ${card.upstream.length} 条洞察',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
            ],
          ),
          const SizedBox(height: 10),
          _row('优势', card.custom['advantage'] as String? ?? ''),
          const SizedBox(height: 6),
          _row('概要', card.custom['summary'] as String? ?? ''),
          const SizedBox(height: 6),
          _row('资源与价格', card.custom['resources'] as String? ?? ''),
          if ((card.custom['keyAssumption'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text('关键假设：${card.custom['keyAssumption']}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999), fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE6E6E6)),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => state.toggleStrategySelect(card.id),
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
                    controller: TextEditingController(text: card.custom['clientNote'] as String? ?? ''),
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
                    onChanged: (v) => state.updateClientNote(card.id, v),
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

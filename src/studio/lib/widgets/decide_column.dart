import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qtconsult_studio/models/ooda_data.dart';
import 'package:qtconsult_studio/services/ooda_state.dart';

class DecideColumn extends StatelessWidget {
  const DecideColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OodaState>(
      builder: (context, state, _) {
        return _ColumnLayout(strategies: state.data.strategies);
      },
    );
  }
}

class _ColumnLayout extends StatelessWidget {
  final List<StrategyCard> strategies;

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
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              children: strategies
                  .map((s) => _StrategyCardWidget(strategy: s))
                  .toList(),
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
      child: const Row(
        children: [
          Icon(Icons.account_tree_outlined, size: 14, color: Color(0xFF444444)),
          SizedBox(width: 6),
          Text(
            '决策 · Decide',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),
          Spacer(),
          Text(
            '2 套方案',
            style: TextStyle(fontSize: 10, color: Color(0xFFAAAAAA)),
          ),
        ],
      ),
    );
  }
}

class _StrategyCardWidget extends StatelessWidget {
  final StrategyCard strategy;

  const _StrategyCardWidget({required this.strategy});

  @override
  Widget build(BuildContext context) {
    final state = context.read<OodaState>();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: strategy.isSelected
              ? const Color(0xFF222222)
              : const Color(0xFFE0E0E0),
          width: strategy.isSelected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(6),
        color: strategy.isSelected
            ? const Color(0xFFFAFAFA)
            : Colors.white,
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
                      child: Text(
                        strategy.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ),
                    if (strategy.priority.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          strategy.priority,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '关联 ${strategy.linkedInsightCount} 条洞察',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFAAAAAA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _row('优势', strategy.advantage),
          const SizedBox(height: 4),
          _row('概要', strategy.summary),
          const SizedBox(height: 4),
          _row('资源与价格', strategy.resources),
          if (strategy.keyAssumption.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '关键假设：${strategy.keyAssumption}',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFFAAAAAA),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () => state.toggleStrategySelect(strategy.id),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: strategy.isSelected
                              ? const Color(0xFF444444)
                              : const Color(0xFFCCCCCC),
                        ),
                        borderRadius: BorderRadius.circular(3),
                        color: strategy.isSelected
                            ? const Color(0xFF444444)
                            : Colors.transparent,
                      ),
                      child: strategy.isSelected
                          ? const Icon(Icons.check, size: 11, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '倾向本方案',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF444444),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 28,
                  child: TextField(
                    controller: TextEditingController(text: strategy.clientNote),
                    style: const TextStyle(fontSize: 10, color: Color(0xFF666666)),
                    decoration: InputDecoration(
                      hintText: '填写顾虑或条件……',
                      hintStyle: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFCCCCCC),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      isDense: true,
                    ),
                    onChanged: (v) => state.updateClientNote(strategy.id, v),
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
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label：',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF222222),
            ),
          ),
          TextSpan(
            text: text,
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

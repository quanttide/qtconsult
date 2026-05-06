import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qtconsult_studio/models/ooda_data.dart';
import 'package:qtconsult_studio/services/ooda_state.dart';

class ObserveColumn extends StatelessWidget {
  const ObserveColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OodaState>(
      builder: (context, state, _) {
        final data = state.data;
        return _ColumnLayout(
          ideals: data.ideals,
          realities: data.realities,
        );
      },
    );
  }
}

class _ColumnLayout extends StatelessWidget {
  final List<ObserveCard> ideals;
  final List<ObserveCard> realities;

  const _ColumnLayout({required this.ideals, required this.realities});

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
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
                children: [
                _subHeader('业务理想', ideals.length),
                ...ideals.map((c) => _ObserveCardWidget(card: c)),
                const SizedBox(height: 14),
                _subHeader('现实状况', realities.length),
                ...realities.map((c) => _ObserveCardWidget(card: c)),
              ],
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
          Icon(Icons.search_outlined, size: 16, color: Color(0xFF333333)),
          SizedBox(width: 8),
          Text(
            '调研 · Observe',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          Spacer(),
          Text(
            '8 条',
            style: TextStyle(fontSize: 11, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }

  Widget _subHeader(String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _ObserveCardWidget extends StatelessWidget {
  final ObserveCard card;

  const _ObserveCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    final state = context.read<OodaState>();
    final isConfirmed = card.status == CardStatus.confirmed;
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
                child: Text(
                  card.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => state.toggleObserveConfirm(card.id),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isConfirmed
                          ? const Color(0xFF333333)
                          : const Color(0xFFCCCCCC),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    color:
                        isConfirmed ? const Color(0xFF333333) : Colors.transparent,
                  ),
                  child: isConfirmed
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            card.body,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
              height: 1.6,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                card.source,
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isConfirmed
                      ? const Color(0xFFF2F2F2)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isConfirmed ? '已确认' : '待确认',
                  style: TextStyle(
                    fontSize: 11,
                    color: isConfirmed
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFF888888),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

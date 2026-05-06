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
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
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
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: const Row(
        children: [
          Icon(Icons.search_outlined, size: 14, color: Color(0xFF444444)),
          SizedBox(width: 6),
          Text(
            '调研 · Observe',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),
          Spacer(),
          Text(
            '8 条',
            style: TextStyle(fontSize: 10, color: Color(0xFFAAAAAA)),
          ),
        ],
      ),
    );
  }

  Widget _subHeader(String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF777777),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(fontSize: 9, color: Color(0xFFAAAAAA)),
          ),
          const Spacer(),
          Container(
            height: 1,
            color: const Color(0xFFEEEEEE),
          ),
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
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isConfirmed ? const Color(0xFF444444) : const Color(0xFFCCCCCC),
            width: 3,
          ),
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  card.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF222222),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => state.toggleObserveConfirm(card.id),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isConfirmed
                          ? const Color(0xFF444444)
                          : const Color(0xFFCCCCCC),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(3),
                    color:
                        isConfirmed ? const Color(0xFF444444) : Colors.transparent,
                  ),
                  child: isConfirmed
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
          if (card.subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              card.subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF888888),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            card.body,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF777777),
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                card.source,
                style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isConfirmed
                      ? const Color(0xFFEEEEEE)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isConfirmed ? '已确认' : '待确认',
                  style: TextStyle(
                    fontSize: 9,
                    color: isConfirmed
                        ? const Color(0xFF222222)
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

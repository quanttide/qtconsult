import 'package:flutter/material.dart';
import 'package:qtconsult_studio/widgets/observe_column.dart';
import 'package:qtconsult_studio/widgets/orient_column.dart';
import 'package:qtconsult_studio/widgets/decide_column.dart';
import 'package:qtconsult_studio/widgets/act_column.dart';

class OodaScreen extends StatelessWidget {
  const OodaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          if (isMobile) {
            return _buildMobile();
          }
          return _buildDesktop();
        },
      ),
    );
  }

  Widget _buildDesktop() {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final colWidth = (constraints.maxWidth - 42) / 4;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: colWidth * 1.4, child: const ObserveColumn()),
                    const SizedBox(width: 14),
                    SizedBox(width: colWidth, child: const OrientColumn()),
                    const SizedBox(width: 14),
                    SizedBox(width: colWidth * 1.2, child: const DecideColumn()),
                    const SizedBox(width: 14),
                    SizedBox(width: colWidth * 0.4, child: const ActColumn()),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: const Column(
        children: [
          SizedBox(height: 8),
          ObserveColumn(),
          SizedBox(height: 10),
          OrientColumn(),
          SizedBox(height: 10),
          DecideColumn(),
          SizedBox(height: 10),
          ActColumn(),
        ],
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
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF444444),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '咨询服务看板',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF888888),
          ),
        ),
      ],
    );
  }
}

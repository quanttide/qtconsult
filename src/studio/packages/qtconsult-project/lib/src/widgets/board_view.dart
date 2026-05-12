import 'package:flutter/material.dart';

class BoardView extends StatelessWidget {
  final Widget? header;
  final List<({Widget child, double flex})> columns;

  const BoardView({
    super.key,
    this.header,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        if (isMobile) return _buildMobile();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _buildDesktop(constraints),
        );
      },
    );
  }

  Widget _buildDesktop(BoxConstraints constraints) {
    final gap = 14.0;
    final paddedWidth = constraints.maxWidth - 32;
    final totalGaps = (columns.length - 1) * gap;
    final totalFlex = columns.fold(0.0, (a, c) => a + c.flex);
    final unitWidth = (paddedWidth - totalGaps) / totalFlex;

    return Column(
      children: [
        if (header != null) ...[header!, const SizedBox(height: 8)],
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < columns.length; i++) ...[
                if (i > 0) const SizedBox(width: 14),
                SizedBox(width: unitWidth * columns[i].flex, child: columns[i].child),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          if (header != null) header!,
          const SizedBox(height: 8),
          for (final col in columns) ...[
            col.child,
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

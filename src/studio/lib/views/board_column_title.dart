import 'package:flutter/material.dart';

/// 看板列标题行：图标 + 名称 + 数量。
class BoardColumnTitle extends StatelessWidget {
  /// 标题左侧图标。
  final IconData icon;

  /// 列标题文本。
  final String title;

  /// 右侧数量文本。
  final String count;

  /// 创建看板列标题。
  const BoardColumnTitle({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF333333)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            count,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
          ),
        ),
      ],
    );
  }
}

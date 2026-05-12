import 'package:flutter/material.dart';

class BoardColumnTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String count;

  const BoardColumnTitle({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: const Color(0xFF333333)),
      const SizedBox(width: 8),
      Flexible(
        child: Text(title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
      ),
      const Spacer(),
      Flexible(
        child: Text(count,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
      ),
    ]);
  }
}

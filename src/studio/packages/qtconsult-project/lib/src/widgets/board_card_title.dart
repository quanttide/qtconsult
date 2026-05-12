import 'package:flutter/material.dart';

class BoardCardTitle extends StatelessWidget {
  final String text;

  const BoardCardTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A1A)));
  }
}

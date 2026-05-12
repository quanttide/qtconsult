import 'package:flutter/material.dart';

class BoardCardDescription extends StatelessWidget {
  final String text;

  const BoardCardDescription({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.6),
        maxLines: 2, overflow: TextOverflow.ellipsis);
  }
}

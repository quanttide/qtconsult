import 'package:flutter/material.dart';

class BoardCard extends StatelessWidget {
  final Widget content;
  final void Function()? onTap;

  const BoardCard({
    super.key,
    required this.content,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: content,
        ),
      ),
    );
  }
}

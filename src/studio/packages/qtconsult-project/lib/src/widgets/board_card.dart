import 'package:flutter/material.dart';

class BoardCard extends StatelessWidget {
  final Widget title;
  final Widget? description;
  final void Function()? onTap;

  const BoardCard({
    super.key,
    required this.title,
    this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE6E6E6)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              if (description != null) ...[
                const SizedBox(height: 6),
                description!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

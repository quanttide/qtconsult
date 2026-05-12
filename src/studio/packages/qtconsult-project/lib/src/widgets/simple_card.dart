import 'package:flutter/material.dart';
import 'package:quanttide_project/quanttide_project.dart';

class SimpleCard extends StatelessWidget {
  final Task task;

  const SimpleCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E6E6)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A1A))),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
          ],
        ],
      ),
    );
  }
}

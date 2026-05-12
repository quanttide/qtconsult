import 'package:flutter/material.dart';
import 'package:qtconsult_project/qtconsult_project.dart';
import 'package:flutter_quanttide_project/flutter_quanttide_project.dart' hide BoardCard;

class StageColumn extends StatelessWidget {
  final BoardColumnTitle title;
  final Widget content;

  const StageColumn({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return BoardColumn(title: title, content: content);
  }
}

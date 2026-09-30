import 'package:flutter/material.dart';
import 'package:flutter_quanttide_project/flutter_quanttide_project.dart'
    hide BoardCard;

import 'board_column_title.dart';

/// 看板阶段列：将标题与内容装配为通用看板列。
class StageColumn extends StatelessWidget {
  /// 列标题组件。
  final BoardColumnTitle title;

  /// 列内容组件（通常为可滚动列表）。
  final Widget content;

  /// 创建阶段列。
  const StageColumn({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return BoardColumn(title: title, content: content);
  }
}

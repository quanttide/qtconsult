import 'package:flutter/material.dart';

Color statusColor(String? status) {
  switch (status) {
    case 'pending':
      return const Color(0xFFAAAAAA);
    case 'confirmed':
      return const Color(0xFF444444);
    default:
      return const Color(0xFFAAAAAA);
  }
}

Color taskStatusColor(String? status) {
  switch (status) {
    case 'todo':
      return const Color(0xFFBBBBBB);
    case 'doing':
      return const Color(0xFF666666);
    case 'done':
      return const Color(0xFF444444);
    case 'blocked':
      return const Color(0xFF999999);
    default:
      return const Color(0xFFBBBBBB);
  }
}

String taskStatusLabel(String? status) {
  switch (status) {
    case 'todo':
      return '待开始';
    case 'doing':
      return '进行中';
    case 'done':
      return '已完成';
    case 'blocked':
      return '受阻';
    default:
      return '待开始';
  }
}

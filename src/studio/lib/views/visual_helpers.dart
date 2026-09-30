import 'package:flutter/material.dart';

/// 按任务确认状态取色：已确认深色，其余浅灰。
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

/// 按执行进度状态取色：待开始、进行中、已完成、受阻各有对应灰阶。
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

/// 执行进度状态的中文文案，未知状态回退为“待开始”。
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

import 'board.dart';

/// 项目。持有一个 [Board] 作为其看板数据。
class Project {
  /// 项目标识名。
  final String name;

  /// 项目显示标题。
  final String title;

  // ===== 看板 =====

  /// 项目的看板数据，包含一组具名列表。
  final Board board;

  const Project({
    required this.name,
    required this.title,
    required this.board,
  });

  /// 从 JSON Map 构造。
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      name: json['name'] as String,
      title: json['title'] as String,
      board: Board.fromJson(json['board'] as Map<String, dynamic>),
    );
  }

  /// 序列化为 JSON Map。
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title': title,
      'board': board.toJson(),
    };
  }
}

import 'board_card.dart';

/// 具名看板列表。一个看板由多个 [BoardList] 组成。
class BoardList {
  /// 列表名称，如 "todo"、"done" 或 "observe"。
  final String name;

  /// 列表中的卡片集合。
  final List<BoardCard> cards;

  const BoardList({
    required this.name,
    required this.cards,
  });
}

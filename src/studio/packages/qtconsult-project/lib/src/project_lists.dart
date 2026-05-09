import 'package:flutter_quanttide_project/flutter_quanttide_project.dart';

class ProjectLists {
  final Board board;

  const ProjectLists({required this.board});

  List<BoardCard> get observe => board.lists['observe']?.cards ?? [];
  List<BoardCard> get orient => board.lists['orient']?.cards ?? [];
  List<BoardCard> get decide => board.lists['decide']?.cards ?? [];
  List<BoardCard> get act => board.lists['act']?.cards ?? [];

  List<BoardCard> get ideals =>
      observe.where((c) => c.category == 'ideal').toList();
  List<BoardCard> get realities =>
      observe.where((c) => c.category == 'reality').toList();

  List<BoardCardCluster> get clusters {
    final map = <String, List<BoardCard>>{};
    for (final card in orient) {
      final key = card.types ?? '未分类';
      map.putIfAbsent(key, () => []).add(card);
    }
    return map.entries
        .map((e) => BoardCardCluster(name: e.key, cards: e.value))
        .toList();
  }
}

class BoardCardCluster {
  final String name;
  final List<BoardCard> cards;
  const BoardCardCluster({required this.name, required this.cards});
}

extension ProjectOodaExtension on Project {
  ProjectLists get lists => ProjectLists(board: board);
}

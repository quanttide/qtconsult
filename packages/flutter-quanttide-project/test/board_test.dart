import 'package:test/test.dart';
import 'package:flutter_quanttide_project/flutter_quanttide_project.dart';

void main() {
  group('Board / BoardList / Project round trip', () {
    test('Project toJson then fromJson preserves data', () {
      final project = Project(
        name: 'test',
        title: '测试项目',
        board: Board(lists: {
          'observe': BoardList(name: 'observe', cards: [
            BoardCard(id: 'o1', title: '卡片1', category: 'ideal',
                custom: {'status': 'pending'}),
          ]),
          'orient': BoardList(name: 'orient', cards: [
            BoardCard(id: 'i1', title: '洞察1', tags: {'domain': '技术领域'}),
          ]),
          'decide': BoardList(name: 'decide', cards: [
            BoardCard(id: 's1', title: '方案A', custom: {'isSelected': true}),
          ]),
          'act': BoardList(name: 'act', cards: [
            BoardCard(id: 't1', title: '任务1', assignee: '某人'),
          ]),
        }),
      );

      final json = project.toJson();
      final restored = Project.fromJson(json);

      expect(restored.name, 'test');
      expect(restored.title, '测试项目');
      expect(restored.board.lists.length, 4);
      expect(restored.board.lists['observe']!.cards.length, 1);
      expect(restored.board.lists['observe']!.cards[0].id, 'o1');
      expect(restored.board.lists['orient']!.cards[0].tags, {'domain': '技术领域'});
      expect(restored.board.lists['decide']!.cards[0].custom['isSelected'], true);
      expect(restored.board.lists['act']!.cards[0].assignee, '某人');
    });

    test('Board.fromJson parses dynamic list names', () {
      final json = {
        'tasks': [{'id': 't1', 'title': '任务'}],
        'ideas': [{'id': 'i1', 'title': '想法'}],
      };
      final board = Board.fromJson(json);
      expect(board.lists.length, 2);
      expect(board.lists.containsKey('tasks'), true);
      expect(board.lists.containsKey('ideas'), true);
    });
  });
}

import 'package:test/test.dart';
import 'package:flutter_quanttide_project/flutter_quanttide_project.dart';

void main() {
  group('BoardCard', () {
    test('copyWith 覆盖部分字段', () {
      final card = BoardCard(id: 'o1', title: '原标题', category: 'ideal',
          custom: {'status': 'pending'});
      final copied = card.copyWith(category: 'reality');
      expect(copied.id, 'o1');
      expect(copied.title, '原标题');
      expect(copied.category, 'reality');
      expect(copied.custom['status'], 'pending');
    });

    test('copyWith 不传参保留原值', () {
      final card = BoardCard(id: 'o1', title: '标题', category: 'ideal',
          custom: {});
      final copied = card.copyWith();
      expect(copied.title, '标题');
      expect(copied.category, 'ideal');
    });

    test('toJson 包含自定义字段', () {
      final card = BoardCard(id: 'o1', title: '卡片',
          custom: {'status': 'confirmed', 'source': '访谈'});
      final json = card.toJson();
      expect(json['id'], 'o1');
      expect(json['status'], 'confirmed');
      expect(json['source'], '访谈');
    });

    test('fromJson 分离自定义字段', () {
      final json = {
        'id': 'o1', 'title': '卡片', 'category': 'ideal',
        'status': 'confirmed', 'source': '访谈',
      };
      final card = BoardCard.fromJson(json);
      expect(card.category, 'ideal');
      expect(card.custom['status'], 'confirmed');
      expect(card.custom['source'], '访谈');
    });
  });
}

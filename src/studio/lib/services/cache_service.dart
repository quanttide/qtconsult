import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:qtconsult_studio/models/ooda_data.dart';

class CacheService {
  final String filePath;

  CacheService({required this.filePath});

  Future<Project?> load() async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      return Project.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Cache load error: $e');
      return null;
    }
  }

  Future<void> save(Project project) async {
    try {
      final file = File(filePath);
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(_toJson(project)));
    } catch (e) {
      debugPrint('Cache save error: $e');
    }
  }

  Map<String, dynamic> _toJson(Project project) {
    return {
      'name': project.name,
      'title': project.title,
      'lists': {
        'observe': project.lists.observe.map(_cardToJson).toList(),
        'orient': project.lists.orient.map(_cardToJson).toList(),
        'decide': project.lists.decide.map(_cardToJson).toList(),
        'act': project.lists.act.map(_cardToJson).toList(),
      },
    };
  }

  Map<String, dynamic> _cardToJson(BoardCard card) {
    final map = <String, dynamic>{
      'id': card.id,
      'title': card.title,
      'description': card.description,
    };
    if (card.category != null) map['category'] = card.category;
    if (card.types != null) map['types'] = card.types;
    if (card.tags.isNotEmpty) map['tags'] = card.tags;
    if (card.date != null) map['date'] = card.date;
    if (card.assignee != null) map['assignee'] = card.assignee;
    if (card.upstream.isNotEmpty) map['upstream'] = card.upstream;
    map.addAll(card.custom);
    return map;
  }
}

import 'package:flutter/material.dart';

// ===== 统一卡片模型 =====

class BoardCard {
  final String id;
  final String title;
  final String description;
  final String? category;
  final String? types;
  final List<String> tags;
  final dynamic date;
  final String? assignee;
  final List<String> upstream;
  final Map<String, dynamic> custom;

  const BoardCard({
    required this.id,
    required this.title,
    this.description = '',
    this.category,
    this.types,
    this.tags = const [],
    this.date,
    this.assignee,
    this.upstream = const [],
    this.custom = const {},
  });

  factory BoardCard.fromJson(Map<String, dynamic> json) {
    final builtIn = {
      'id', 'title', 'description', 'category', 'types',
      'tags', 'date', 'assignee', 'upstream',
    };
    final custom = <String, dynamic>{};
    json.forEach((key, value) {
      if (!builtIn.contains(key)) custom[key] = value;
    });
    return BoardCard(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String?,
      types: json['types'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      date: json['date'],
      assignee: json['assignee'] as String?,
      upstream: (json['upstream'] as List<dynamic>?)?.cast<String>() ?? [],
      custom: custom,
    );
  }

  BoardCard copyWith({String? category, String? types, String? assignee}) {
    return BoardCard(
      id: id,
      title: title,
      description: description,
      category: category ?? this.category,
      types: types ?? this.types,
      tags: tags,
      date: date,
      assignee: assignee ?? this.assignee,
      upstream: upstream,
      custom: custom,
    );
  }
}

// ===== 看板结构 =====

class ProjectLists {
  final List<BoardCard> observe;
  final List<BoardCard> orient;
  final List<BoardCard> decide;
  final List<BoardCard> act;

  const ProjectLists({
    required this.observe,
    required this.orient,
    required this.decide,
    required this.act,
  });

  List<BoardCard> get ideals => observe.where((c) => c.category == 'ideal').toList();
  List<BoardCard> get realities => observe.where((c) => c.category == 'reality').toList();

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

  factory ProjectLists.fromJson(Map<String, dynamic> json) {
    return ProjectLists(
      observe: _parseCards(json['observe']),
      orient: _parseCards(json['orient']),
      decide: _parseCards(json['decide']),
      act: _parseCards(json['act']),
    );
  }

  static List<BoardCard> _parseCards(dynamic value) {
    return (value as List<dynamic>)
        .map((c) => BoardCard.fromJson(c as Map<String, dynamic>))
        .toList();
  }
}

class BoardCardCluster {
  final String name;
  final List<BoardCard> cards;
  const BoardCardCluster({required this.name, required this.cards});
}

class Project {
  final String name;
  final String title;
  final ProjectLists lists;

  const Project({required this.name, required this.title, required this.lists});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      name: json['name'] as String,
      title: json['title'] as String,
      lists: ProjectLists.fromJson(json['lists'] as Map<String, dynamic>),
    );
  }
}

// ===== 视觉工具 =====

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

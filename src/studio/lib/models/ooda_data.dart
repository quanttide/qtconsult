import 'package:flutter/material.dart';

// ===== Enums =====

enum CardStatus { pending, confirmed }

enum TaskStatus { todo, doing, done, blocked }

enum Stance { support, neutral, oppose }

// ===== 调研层 =====

class ObserveCard {
  final String id;
  final String title;
  final String subtitle;
  final String body;
  final String source;
  final String date;
  final CardStatus status;
  final bool isIdeal; // true=业务理想, false=现实状况

  const ObserveCard({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.body,
    required this.source,
    required this.date,
    this.status = CardStatus.pending,
    required this.isIdeal,
  });

  factory ObserveCard.fromJson(Map<String, dynamic> json) {
    return ObserveCard(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      body: json['body'] as String,
      source: json['source'] as String,
      date: json['date'] as String,
      status: CardStatus.values.byName(json['status'] as String),
      isIdeal: json['isIdeal'] as bool,
    );
  }

  ObserveCard copyWith({CardStatus? status}) {
    return ObserveCard(
      id: id,
      title: title,
      subtitle: subtitle,
      body: body,
      source: source,
      date: date,
      status: status ?? this.status,
      isIdeal: isIdeal,
    );
  }
}

// ===== 分析层 =====

class InsightEvidence {
  final String label;
  final String observeCardId;

  const InsightEvidence({required this.label, required this.observeCardId});

  factory InsightEvidence.fromJson(Map<String, dynamic> json) {
    return InsightEvidence(
      label: json['label'] as String,
      observeCardId: json['observeCardId'] as String,
    );
  }
}

class InsightCard {
  final String id;
  final String title;
  final String rootCause;
  final String impact;
  final List<InsightEvidence> evidences;
  final String cluster;

  const InsightCard({
    required this.id,
    required this.title,
    required this.rootCause,
    required this.impact,
    this.evidences = const [],
    required this.cluster,
  });

  factory InsightCard.fromJson(Map<String, dynamic> json) {
    return InsightCard(
      id: json['id'] as String,
      title: json['title'] as String,
      rootCause: json['rootCause'] as String,
      impact: json['impact'] as String,
      evidences: (json['evidences'] as List<dynamic>?)
              ?.map((e) => InsightEvidence.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cluster: json['cluster'] as String,
    );
  }
}

class InsightCluster {
  final String name;
  final List<InsightCard> insights;

  const InsightCluster({required this.name, required this.insights});
}

// ===== 决策层 =====

class StrategyCard {
  final String id;
  final String name;
  final String priority;
  final int linkedInsightCount;
  final String advantage;
  final String summary;
  final String resources;
  final String keyAssumption;
  final bool isSelected;
  final String clientNote;

  const StrategyCard({
    required this.id,
    required this.name,
    this.priority = '',
    this.linkedInsightCount = 0,
    required this.advantage,
    required this.summary,
    required this.resources,
    this.keyAssumption = '',
    this.isSelected = false,
    this.clientNote = '',
  });

  factory StrategyCard.fromJson(Map<String, dynamic> json) {
    return StrategyCard(
      id: json['id'] as String,
      name: json['name'] as String,
      priority: json['priority'] as String? ?? '',
      linkedInsightCount: json['linkedInsightCount'] as int? ?? 0,
      advantage: json['advantage'] as String,
      summary: json['summary'] as String,
      resources: json['resources'] as String,
      keyAssumption: json['keyAssumption'] as String? ?? '',
      isSelected: json['isSelected'] as bool? ?? false,
      clientNote: json['clientNote'] as String? ?? '',
    );
  }

  StrategyCard copyWith({bool? isSelected, String? clientNote}) {
    return StrategyCard(
      id: id,
      name: name,
      priority: priority,
      linkedInsightCount: linkedInsightCount,
      advantage: advantage,
      summary: summary,
      resources: resources,
      keyAssumption: keyAssumption,
      isSelected: isSelected ?? this.isSelected,
      clientNote: clientNote ?? this.clientNote,
    );
  }
}

// ===== 执行层 =====

class TaskCard {
  final String id;
  final String name;
  final TaskStatus status;
  final String linkedStrategy;
  final String assignee;
  final String startDate;
  final String endDate;
  final String notes;
  final String blockedReason;
  final double progress;

  const TaskCard({
    required this.id,
    required this.name,
    this.status = TaskStatus.todo,
    this.linkedStrategy = '',
    this.assignee = '',
    this.startDate = '',
    this.endDate = '',
    this.notes = '',
    this.blockedReason = '',
    this.progress = 0.0,
  });

  factory TaskCard.fromJson(Map<String, dynamic> json) {
    return TaskCard(
      id: json['id'] as String,
      name: json['name'] as String,
      status: TaskStatus.values.byName(json['status'] as String),
      linkedStrategy: json['linkedStrategy'] as String? ?? '',
      assignee: json['assignee'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      blockedReason: json['blockedReason'] as String? ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ===== 顶层容器 =====

class OodaData {
  final List<ObserveCard> observes;
  final List<InsightCard> insights;
  final List<StrategyCard> strategies;
  final List<TaskCard> tasks;

  const OodaData({
    required this.observes,
    required this.insights,
    required this.strategies,
    required this.tasks,
  });

  List<InsightCluster> get clusters {
    final map = <String, List<InsightCard>>{};
    for (final insight in insights) {
      map.putIfAbsent(insight.cluster, () => []).add(insight);
    }
    return map.entries
        .map((e) => InsightCluster(name: e.key, insights: e.value))
        .toList();
  }

  List<ObserveCard> get ideals => observes.where((c) => c.isIdeal).toList();
  List<ObserveCard> get realities => observes.where((c) => !c.isIdeal).toList();

  factory OodaData.fromJson(Map<String, dynamic> json) {
    return OodaData(
      observes: (json['observes'] as List<dynamic>)
          .map((c) => ObserveCard.fromJson(c as Map<String, dynamic>))
          .toList(),
      insights: (json['insights'] as List<dynamic>)
          .map((c) => InsightCard.fromJson(c as Map<String, dynamic>))
          .toList(),
      strategies: (json['strategies'] as List<dynamic>)
          .map((c) => StrategyCard.fromJson(c as Map<String, dynamic>))
          .toList(),
      tasks: (json['tasks'] as List<dynamic>)
          .map((c) => TaskCard.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ===== 视觉工具 =====

Color statusColor(CardStatus status) {
  switch (status) {
    case CardStatus.pending:
      return const Color(0xFFAAAAAA);
    case CardStatus.confirmed:
      return const Color(0xFF444444);
  }
}

Color taskStatusColor(TaskStatus status) {
  switch (status) {
    case TaskStatus.todo:
      return const Color(0xFFBBBBBB);
    case TaskStatus.doing:
      return const Color(0xFF666666);
    case TaskStatus.done:
      return const Color(0xFF444444);
    case TaskStatus.blocked:
      return const Color(0xFF999999);
  }
}

String taskStatusLabel(TaskStatus status) {
  switch (status) {
    case TaskStatus.todo:
      return '待开始';
    case TaskStatus.doing:
      return '进行中';
    case TaskStatus.done:
      return '已完成';
    case TaskStatus.blocked:
      return '受阻';
  }
}

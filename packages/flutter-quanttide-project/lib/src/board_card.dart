/// 看板卡片。
///
/// 支持内置字段和自定义字段。
/// 自定义字段通过 [custom] Map 存储，序列化时合并到 JSON 根层级。
class BoardCard {
  /// 卡片唯一标识。
  final String id;

  /// 卡片标题。
  final String title;

  /// 卡片详细描述。
  final String description;

  /// 系统分类。如 ideal / reality，含义由上层业务约定。
  final String? category;

  /// 问题领域。如"技术领域"、"数据基建"，可选多个类型参考。
  final String? types;

  /// 灵活标签列表。
  final List<String> tags;

  /// 日期信息。支持 String 单日期或 Map 起止日期。
  final dynamic date;

  /// 负责人。
  final String? assignee;

  /// 上游卡片 ID 列表，用于卡片间引用链路。
  final List<String> upstream;

  /// 自定义字段。不在内置字段列表中的 JSON 键值对均归入此 Map。
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

  /// 从 JSON Map 构造。内置字段（id, title 等）被提取为命名属性，
  /// 其余字段自动归入 [custom]。
  factory BoardCard.fromJson(Map<String, dynamic> json) {
    const builtIn = {
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

  /// 创建当前卡片的副本，可选覆盖部分字段。
  BoardCard copyWith({
    String? category,
    String? types,
    String? assignee,
  }) {
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

  /// 序列化为 JSON Map。自定义字段展开到根层级。
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
    };
    if (category != null) map['category'] = category;
    if (types != null) map['types'] = types;
    if (tags.isNotEmpty) map['tags'] = tags;
    if (date != null) map['date'] = date;
    if (assignee != null) map['assignee'] = assignee;
    if (upstream.isNotEmpty) map['upstream'] = upstream;
    map.addAll(custom);
    return map;
  }
}

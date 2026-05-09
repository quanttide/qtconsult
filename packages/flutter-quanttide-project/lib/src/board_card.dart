/// 看板卡片。
///
/// 字段分四组：
/// - **标识**：id、title、description
/// - **分类**：category（系统分类）、tags（多维度标签，Map<String, String>）
/// - **上下文**：date（时间）、assignee（负责人）
/// - **扩展**：custom（自定义字段，序列化时展开到 JSON 根层级）
class BoardCard {
  // ===== 标识 =====

  /// 卡片唯一标识。
  final String id;

  /// 卡片标题。
  final String title;

  /// 卡片详细描述。
  final String description;

  // ===== 分类 =====

  /// 系统分类。由上层业务约定，如 OODA 中区分 ideal（业务理想）和 reality（现实状况）。
  final String? category;

  /// 标签 Map，用于多维度标记和筛选。键为维度名，值为标签值。
  ///
  /// 示例：{"domain": "sales", "priority": "high", "status": "active"}
  final Map<String, String> tags;

  // ===== 上下文 =====

  /// 日期信息。支持 String 单日期（"2024-01-15"）或 Map 起止日期。
  final dynamic date;

  /// 负责人。
  final String? assignee;

  // ===== 扩展 =====

  /// 自定义字段。不在内置字段列表中的 JSON 键值对均归入此 Map。
  /// 序列化时展开到 JSON 根层级，与内置字段平级。
  final Map<String, dynamic> custom;

  const BoardCard({
    required this.id,
    required this.title,
    this.description = '',
    this.category,
    this.tags = const {},
    this.date,
    this.assignee,
    this.custom = const {},
  });

  /// 从 JSON Map 构造。内置字段（id, title 等）被提取为命名属性，
  /// 其余字段自动归入 [custom]。
  factory BoardCard.fromJson(Map<String, dynamic> json) {
    const builtIn = {
      'id', 'title', 'description', 'category',
      'tags', 'date', 'assignee',
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
      tags: json['tags'] is Map
          ? (json['tags'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v.toString()))
          : {},
      date: json['date'],
      assignee: json['assignee'] as String?,
      custom: custom,
    );
  }

  /// 创建当前卡片的副本，可选覆盖部分字段。
  BoardCard copyWith({
    String? category,
    String? assignee,
  }) {
    return BoardCard(
      id: id,
      title: title,
      description: description,
      category: category ?? this.category,
      tags: tags,
      date: date,
      assignee: assignee ?? this.assignee,
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
    if (tags.isNotEmpty) map['tags'] = tags;
    if (date != null) map['date'] = date;
    if (assignee != null) map['assignee'] = assignee;
    map.addAll(custom);
    return map;
  }
}

# flutter-quanttide-project

看板项目领域模型。为 `quanttide-project-toolkit` 的 Flutter 实现奠定基础。

## 模型

| 类 | 说明 |
|---|---|
| `BoardCard` | 看板卡片，支持内置字段 + 自定义字段 |
| `BoardList` | 具名卡片列表 |
| `Board` | 看板，包含 `Map<String, BoardList>` |
| `Project` | 项目，持有一个 `Board` |

不包含任何业务特化逻辑（如 OODA），仅提供通用的看板数据结构。

## 使用

```dart
import 'package:flutter_quanttide_project/flutter_quanttide_project.dart';

final project = Project(
  name: 'project1',
  title: '示例项目',
  board: Board(lists: {
    'todo': BoardList(name: 'todo', cards: [
      BoardCard(id: 'c1', title: '任务1'),
    ]),
    'done': BoardList(name: 'done', cards: []),
  }),
);

final json = project.toJson();
final restored = Project.fromJson(json);
```

## 依赖关系

```
flutter-quanttide-project  (通用看板模型)
        ↑
qtconsult-project          (OODA 特化适配，studio 内部)
        ↑
qtconsult_studio           (主应用)
```

# 分包方案

## 动机

- `qtconsult_studio` 中的领域模型（Project、BoardCard）是通用概念，可被其他应用共享
- 将通用模型与 OODA 特化逻辑分离，降低耦合
- 为 `quanttide-project-toolkit` 做准备

## 包结构

### `packages/flutter-quanttide-project`（共享）

通用看板领域模型，不含任何业务特化。纯 Dart，零依赖。

```
lib/
  flutter_quanttide_project.dart  # barrel export
  src/
    board_card.dart                # BoardCard（内置字段 + 自定义字段）
    board_list.dart                # BoardList（name + cards）
    board.dart                     # Board（Map<String, BoardList>）
    project.dart                   # Project（name, title, board）
```

**设计要点：**
- `Board.lists` 是 `Map<String, BoardList>`，不预设列表名称
- `BoardCard` 的 `category` 等字段保留，不做业务特化解释
- 不包含任何 Provider/API/Cache 逻辑

### `src/studio/packages/qtconsult-project`

OODA 工作流适配层，提供 Studio 特有的 `ProjectLists` 访问器和视觉辅助函数。

```
lib/
  qtconsult_project.dart     # barrel export（含 flutter_quanttide_project 的全部导出）
  src/
    project_lists.dart       # ProjectLists OODA 适配器 + BoardCardCluster
    visual_helpers.dart      # statusColor / taskStatusColor / taskStatusLabel
```

**依赖：** `flutter_quanttide_project` + `flutter` SDK

### `qtconsult_studio`（主应用）

保留全部 OODA 业务逻辑和 UI。通过 `qtconsult_project` 间接使用领域模型，不再直接引用 `models/ooda_data.dart`。

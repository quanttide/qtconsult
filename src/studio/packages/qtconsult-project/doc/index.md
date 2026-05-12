# 开发思路

## 定位

`qtconsult_project` 是量潮咨询看板的 OODA 特化适配层，位于通用领域模型和咨询 UI 之间。

## 分层关系

```
quanttide_project (pub.dev)        — 通用看板领域模型
  └─ qtconsult_project (私有包)     — OODA 适配层
       └─ src/studio/ (主应用)     — 咨询看板 UI
```

通用层提供 Board、BoardCard、BoardList、Project 等基础模型。本包只在通用层不足时定义自有模型，不扭曲通用层去适配业务。

## 文件职责

| 文件 | 职责 |
|------|------|
| `qtconsult_project.dart` | 入口，re-export 通用模型 + 本包组件 |
| `project_lists.dart` | OODA 四阶段存取、Orient 聚类、Observe 分类、上游追踪 |
| `visual_helpers.dart` | 卡片状态 → 颜色/中文标签映射，供 UI 层直接使用 |

## 核心设计

### OODA 命名存取

Board 的 lists 是 `Map<String, BoardList>`，原始存取需 magic string。`ProjectLists` 封装为四个具名 getter，UI 层只需关心阶段语义，不关心内部 key。

### Orient 聚类

Orient 阶段的卡片按 `tags['domain']` 分组为 `BoardCardCluster`，供看板按领域域（如"组织"、"数据"）聚合展示。聚类逻辑集中在适配层，UI 层直接消费。

### Observe 分类

Observe 阶段区分"理想态"和"现实态"两种卡片，通过 `category` 字段过滤，对应咨询诊断中的差距分析。

### 上游追踪

`BoardCard` 通过扩展方法提供 `upstream` 字段，用于在看板中建立卡片间的前驱依赖链路，支撑决策链可视化。

### 状态视觉映射

卡片状态（`pending`/`confirmed`）和任务状态（`todo`/`doing`/`done`/`blocked`）的色值和中文标签集中在 `visual_helpers.dart`，UI 层直接调用函数取值，不做二次映射。

## 设计原则

- 扩展方法优先于继承：不修改 `quanttide_project` 的通用模型
- 纯函数优先于状态：`statusColor`、`taskStatusColor` 等是纯函数，不依赖 Widget 上下文
- 约定优于配置：OODA 列表 key 固定为 `observe`/`orient`/`decide`/`act`，不通过配置注入
- 抽象不成为瓶颈：当通用模型不满足需求时，直接定义自有模型（如 `BoardCardCluster`）

# 开发思路

## 定位

量潮咨询看板的业务适配层直接落在 `src/studio/lib/` 内（原 `qtconsult_project` 私有包已并入），位于通用领域模型和咨询 UI 之间。

## 分层关系

```
quanttide_project (pub.dev)     — 通用看板领域模型（Project / Task / Board）
  └─ src/studio/lib/             — 业务适配层（models / states）+ 看板 UI（views / screens）
       └─ services/              — 数据服务（provider API、本地缓存）
```

通用层提供 Project、Task 等基础模型。适配层只在通用层不足时定义自有模型，不扭曲通用层去适配业务。

## 文件职责

| 文件 | 职责 |
|------|------|
| `lib/qtconsult_studio.dart` | barrel 入口，re-export 通用模型 + 本应用组件 |
| `lib/models/project_lists.dart` | 四阶段（clarify/research/decide/execute）分组、调研按领域聚类、上游追踪 |
| `lib/states/consult_state.dart` | 看板不可变状态快照（任务列表 + 待回写标记） |
| `lib/states/consult_cubit.dart` | 卡片交互、脏任务跟踪与后台回写 |
| `lib/states/app_cubit.dart` | 数据加载（provider → fixture 回退）与工作区切换 |

## 核心设计

### 四阶段分组

UI 不按原始 key 取任务，`ProjectLists` 把 `type` 过滤封装为四个具名 getter（clarify/research/decide/execute），UI 层只关心阶段语义，不散落 magic string。

### 调研聚类

调研阶段的卡片按 `tags['domain']` 分组为 `TaskCluster`，供看板按领域（如"组织"、"数据"）聚合展示。聚类逻辑集中在适配层，UI 层直接消费。

### 上游追踪

`Task` 通过扩展方法提供 `upstream` 字段（`upstream` 标签，逗号分隔），用于在看板中建立卡片间的前驱依赖链路，支撑决策链可视化。

### 状态与逻辑分离

状态是不可变快照（`ConsultState`），变更只能经 `Cubit` 触发并 emit 新状态；bloc_lint 保证 cubit 文件不依赖 Flutter、不暴露公有字段，可独立测试。

## 设计原则

- 扩展方法优先于继承：不修改 `quanttide_project` 的通用模型
- 约定优于配置：四阶段固定为 `clarify`/`research`/`decide`/`execute`，不通过配置注入
- 抽象不成为瓶颈：当通用模型不满足需求时，直接定义自有模型（如 `TaskCluster`）

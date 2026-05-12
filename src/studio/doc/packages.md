# 重构记录：分层拆包

## 目标

将单体应用拆为三层：

```
src/studio/lib/      (主应用，仅保留入口 + 应用级逻辑)
  └─ packages/
       ├─ data-sources/       (通用基础设施)
       └─ qtconsult-project/  (OODA 领域 + 状态 + UI)
```

两层包各自独立验证架构可用性，不与 qtadmin 共享基础设施。

## 最终结构

### data-sources

通用数据基础设施，不依赖任何 OODA 领域类型。

| 文件 | 职责 |
|------|------|
| `lib/data_sources.dart` | barrel export |
| `lib/cache_service.dart` | 条件导出入口 |
| `lib/cache_service_stub.dart` | 存根（返回 null） |
| `lib/cache_service_io.dart` | 文件系统实现（dart:io） |
| `lib/cache_service_web.dart` | localStorage 实现（dart:html） |
| `lib/provider_service.dart` | HTTP 客户端，返回 `Map<String, dynamic>` |

**关键设计决策**：基础设施不感知领域模型。
- `CacheService` 存储 `String`（raw JSON），调用方自行序列化
- `ProviderService` 返回 `Map<String, dynamic>`，调用方自行反序列化

### qtconsult-project

OODA 领域模型 + 状态管理 + UI 组件。依赖 `data-sources`。

```
lib/
├── qtconsult_project.dart      # barrel export
└── src/
    ├── project_lists.dart       # OODA 存取 + 聚类
    ├── visual_helpers.dart      # 色值/标签映射
    ├── state/
    │   └── ooda_state.dart      # OodaState，通过 data-sources 做持久化
    └── widgets/
        ├── observe_column.dart
        ├── orient_column.dart
        ├── decide_column.dart
        ├── act_column.dart
        ├── ooda_screen.dart
        └── workspace_switcher.dart
```

### 主应用

```
lib/
├── main.dart                        # 应用入口，组装依赖
├── models/ooda_data.dart            # 桥接 re-export
└── screens/workspace_select_screen.dart
```

## 关键变更

### 移动的文件

**主应用 → data-sources：**
- `cache_service.dart`（含 stub/io/web 条件导出）
- `provider_service.dart`（改为返回 `Map`，去掉领域依赖）

**主应用 → qtconsult-project：**
- `ooda_state.dart` → `lib/src/state/`
- `observe_column.dart` → `lib/src/widgets/`
- `orient_column.dart` → `lib/src/widgets/`
- `decide_column.dart` → `lib/src/widgets/`
- `act_column.dart` → `lib/src/widgets/`
- `workspace_switcher.dart` → `lib/src/widgets/`
- `ooda_screen.dart` → `lib/src/widgets/`

**主应用 → qtconsult-project 的测试：**
- `ooda_data_test.dart` → `test/project_lists_test.dart`
- `ooda_state_test.dart` → `test/ooda_state_test.dart`
- `ooda_screen_test.dart` → `test/ooda_screen_test.dart`

**留在主应用的测试：**
- `test/services/provider_service_test.dart`
- `test/widgets/workspace_switcher_test.dart`

### API 变更

| 类 | 变更前 | 变更后 |
|----|--------|--------|
| `CacheService.load()` | 返回 `Project?` | 返回 `String?` |
| `CacheService.save()` | 接收 `Project` | 接收 `String` |
| `ProviderService.loadProject()` | 返回 `Project` | 返回 `Map<String, dynamic>` |
| `ProviderService.updateCard()` | 接收 `BoardCard` | 接收 `Map<String, dynamic>` |

## 依赖关系

```
main_app
  ├─ qtconsult-project
  │    ├─ data-sources
  │    │    └─ http, flutter
  │    └─ quanttide_project (pub.dev)
  │         └─ provider
  └─ data-sources
       └─ http, flutter
```

key libraries removed from main app: `http`, `quanttide_project`（通过 qtconsult-project 传递获得）

## 测试结果

- **qtconsult-project**: 26 个测试全部通过
- **主应用**: 11 个测试全部通过

## 提交记录

- qtconsult 子模块: `f1e3322` — refactor: split into data-sources and qtconsult-project layered packages
- 主仓库: `736b0fc` — chore: update qtconsult submodule (layered package refactor)

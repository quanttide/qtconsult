# 重构方案：分层拆包

## 目标

将单体应用拆为三层：

```
src/studio/lib/      (主应用，仅保留入口 + 应用级逻辑)
  └─ packages/
       ├─ data-sources/       (新增，通用基础设施)
       └─ qtconsult-project/  (OODA 领域 + 状态 + UI)
```

两层包各自独立验证架构可用性，不与 qtadmin 共享基础设施。

## 分层设计

### data-sources

通用数据基础设施，不依赖任何 OODA 领域类型。

| 文件 | 职责 |
|------|------|
| `lib/cache_service.dart` | 条件导出入口 |
| `lib/cache_service_stub.dart` | 存根（无操作） |
| `lib/cache_service_io.dart` | 文件系统实现（dart:io） |
| `lib/cache_service_web.dart` | localStorage 实现（dart:html） |
| `lib/provider_service.dart` | HTTP 客户端，返回 raw `Map`，不感知领域模型 |
| `lib/data_sources.dart` | barrel export |

**关键设计决策**：基础设施不感知领域模型。
- `CacheService` 存储 `String`（raw JSON），调用方自行序列化
- `ProviderService` 返回 `Map<String, dynamic>`，调用方自行反序列化

### qtconsult-project

OODA 领域模型 + 状态管理 + UI 组件。依赖 `data-sources`。

```
lib/
├── qtconsult_project.dart      # barrel export
└── src/
    ├── project_lists.dart       # OODA 存取 + 聚类（已有）
    ├── visual_helpers.dart      # 色值/标签映射（已有）
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

## 范围

### 从主应用移入 qtconsult-project

| 源路径 | 目标路径 | 注意 |
|--------|---------|------|
| `lib/widgets/observe_column.dart` | `lib/src/widgets/` | import 改为 package 路径 |
| `lib/widgets/orient_column.dart` | `lib/src/widgets/` | 同上 |
| `lib/widgets/decide_column.dart` | `lib/src/widgets/` | 同上 |
| `lib/widgets/act_column.dart` | `lib/src/widgets/` | 同上 |
| `lib/widgets/workspace_switcher.dart` | `lib/src/widgets/` | 同上 |
| `lib/screens/ooda_screen.dart` | `lib/src/widgets/` | 同上，去掉 `package:qtconsult_studio` 引用 |
| `lib/services/ooda_state.dart` | `lib/src/state/` | 改造：通过 data-sources 做持久化 |
| `lib/models/ooda_data.dart` | —（删除） | 已经是 barrel export，功能由 qtconsult_project.dart 替代 |

### 从主应用移入 data-sources

| 源路径 | 目标路径 | 变更 |
|--------|---------|------|
| `lib/services/cache_service.dart` | `lib/` | 改为存 raw String |
| `lib/services/cache_service_stub.dart` | `lib/` | 返回 null/空 |
| `lib/services/cache_service_io.dart` | `lib/` | 读写 String |
| `lib/services/cache_service_web.dart` | `lib/` | 读写 String |
| `lib/services/provider_service.dart` | `lib/` | 去掉 Project/BoardCard 依赖，返回 `Map` |

### 从主应用移入 data-sources 的测试

| 源路径 | 目标路径 |
|--------|---------|
| `test/models/ooda_data_test.dart` | `test/project_lists_test.dart` |
| `test/models/ooda_state_test.dart` | `test/ooda_state_test.dart` |
| `test/widgets/ooda_screen_test.dart` | `test/ooda_screen_test.dart` |

### 留在主应用

| 文件 | 理由 |
|------|------|
| `lib/main.dart` | 应用入口，组装依赖 |
| `lib/screens/workspace_select_screen.dart` | 应用级工作区选择 |
| `test/services/provider_service_test.dart` | Provider HTTP 集成测试 |
| `test/widgets/workspace_switcher_test.dart` | WorkspaceSwitcher 单独测试 |

## 依赖关系

```
main_app
  ├─ qtconsult-project
  │    ├─ data-sources
  │    └─ quanttide_project (pub.dev)
  └─ data-sources
       └─ http, flutter
```

### pubspec.yaml 变更

**data-sources（新增）：**
```yaml
name: data_sources
dependencies:
  flutter:
    sdk: flutter
dev_dependencies:
  flutter_test:
    sdk: flutter
```

**qtconsult-project（更新）：**
```yaml
dependencies:
  data_sources:
    path: ../data-sources
  quanttide_project: ^0.1.0
  flutter:
    sdk: flutter
  provider: ^6.1.5    # 新增
```

**主应用 qtconsult_studio（移除直接依赖）：**
```yaml
dependencies:
  data_sources:        # 新增
    path: packages/data-sources
  qtconsult_project:
    path: packages/qtconsult-project
  # quanttide_project 已通过 qtconsult-project 传递
```

## 导入路径变更

### data-sources 包

文件各自使用相对路径 import。

### qtconsult-project

| 旧 import | 新 import |
|-----------|-----------|
| `package:qtconsult_studio/services/cache_service.dart` | `package:data_sources/cache_service.dart` |
| `package:qtconsult_studio/services/provider_service.dart` | `package:data_sources/provider_service.dart` |
| `package:qtconsult_studio/models/ooda_data.dart` | `package:qtconsult_project/qtconsult_project.dart` |
| `package:qtconsult_studio/services/ooda_state.dart` | `package:qtconsult_project/src/state/ooda_state.dart` |
| `package:qtconsult_studio/widgets/*.dart` | `package:qtconsult_project/src/widgets/*.dart` |
| `package:qtconsult_studio/screens/ooda_screen.dart` | `package:qtconsult_project/src/widgets/ooda_screen.dart` |

### 主应用

| 旧 import | 新 import |
|-----------|-----------|
| `package:qtconsult_studio/services/cache_service.dart` | `package:data_sources/cache_service.dart` |
| `package:qtconsult_studio/services/provider_service.dart` | `package:data_sources/provider_service.dart` |
| `package:qtconsult_studio/models/ooda_data.dart` | `package:qtconsult_project/qtconsult_project.dart` |
| `package:qtconsult_studio/services/ooda_state.dart` | `package:qtconsult_project/src/state/ooda_state.dart` |
| `package:qtconsult_studio/screens/ooda_screen.dart` | `package:qtconsult_project/src/widgets/ooda_screen.dart` |

## 执行顺序

1. 创建 `data-sources` 包目录 + pubspec.yaml
2. 编写 `data-sources` 的 5 个 lib 文件
3. 更新 `qtconsult-project/pubspec.yaml`（新增 data_sources、provider 依赖）
4. 将 OODA 组件文件从主应用移到 `qtconsult-project`，修正 import
5. 更新 `qtconsult-project/lib/qtconsult_project.dart` barrel export
6. 更新主应用的 import
7. 移动测试文件，更新 import
8. 运行测试验证

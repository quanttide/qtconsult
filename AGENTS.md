# AGENTS

## 项目概述

量潮咨询服务平台，双端架构：
- `src/provider/` — Python FastAPI 后端
- `src/studio/` — Flutter 前端（咨询看板），单包结构
- 原 `src/studio/packages/`（data-sources、qtconsult-project）已取消，代码合并进 `src/studio/lib/`；`quanttide_project: ^0.2.0` 依赖 pub.dev

## 分层设计

- **`quanttide_project` / `flutter_quanttide_project`** (pub.dev) — 通用看板领域模型与组件（BoardCard, BoardList, Board, Project, Task）
- **`src/studio/lib/`** — 主应用，入口 barrel 为 `lib/qtconsult_studio.dart`
  - `models/` 领域分组模型（ProjectLists）、`states/` 状态（ConsultState）、`views/` 通用组件、`screens/` 页面、`services/` 数据服务（缓存、provider API）
  - 优先复用 `quanttide_project` 的通用模型
  - 当通用层无法满足 OODA 特化需求时，可直接定义自有模型，不必迁就通用层
  - 原则：**抽象不该成为新需求的瓶颈。** 如果为了让某件事符合通用模型而扭曲业务代码，那就是本末倒置

## BoardCard 字段分组

```
// ===== 标识 =====
  id / title / description
// ===== 分类 =====
  category (String?) / tags (Map<String, String>)
// ===== 上下文 =====
  date (dynamic) / assignee (String?)
// ===== 扩展 =====
  custom (Map<String, dynamic>)
```

## 常用命令

```bash
# Flutter 前端
cd src/studio && flutter pub get
cd src/studio && flutter analyze
cd src/studio && flutter test
cd src/studio && flutter build web
cd src/studio && flutter run -d chrome

# Python 后端
cd src/provider && .venv/bin/python -m pytest tests/
cd src/provider && .venv/bin/uvicorn app.main:app --reload

# Bloc 静态检查（一次性安装 CLI）
dart pub global activate bloc_tools
cd src/studio && bloc lint .
```

## 代码约定

- 不添加代码注释（`///` 文档注释除外），公开成员必须有 `///` 文档（`public_member_api_docs` 门禁）
- 不添加多余空行/分隔符以外的格式化
- 领域模型分层：通用模型 → 业务适配 → 应用 UI
- 状态管理用 bloc：状态类 `*State`（`*_state.dart`）、逻辑类 `*Cubit`（`*_cubit.dart`）；bloc_lint 约束 cubit 文件不引 Flutter、公有方法返回 `void`/`Future<void>`、无公有字段
- 环境配置走 `environment_config`：`environment_config.yaml` → `dart run environment_config:generate` → `lib/environment_config.dart`，不用 `--dart-define`
- JSON 键名小写蛇形，`board` 而非 `lists`
- 所有 fixture 同步维护两份：`src/studio/assets/fixtures/` 和 `assets/fixtures/`

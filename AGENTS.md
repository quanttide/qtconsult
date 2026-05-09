# AGENTS

## 项目概述

量潮咨询服务平台，双端架构：
- `src/provider/` — Python FastAPI 后端
- `src/studio/` — Flutter 前端（咨询看板）
- `packages/` 已废弃，`quanttide_project: ^0.1.0` 依赖 pub.dev

## 分包设计

- **`quanttide_project`** (pub.dev) — 通用看板领域模型（BoardCard, BoardList, Board, Project），纯 Dart
- **`src/studio/packages/qtconsult-project`** — OODA 特化适配层（ProjectLists + 视觉辅助），私有包
  - 优先复用 `quanttide_project` 的通用模型
  - 当通用层无法满足 OODA 特化需求时，可直接定义自有模型，不必迁就通用层
  - 原则：**抽象不该成为新需求的瓶颈。** 如果为了让某件事符合通用模型而扭曲业务代码，那就是本末倒置
- **`src/studio/`** — 主应用，通过 `qtconsult-project` 间接使用领域模型

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

# 包测试
cd src/studio/packages/qtconsult-project && flutter pub get && flutter test

# 文档
cd src/studio/packages/qtconsult-project && dart doc
```

## 代码约定

- 不添加代码注释（`///` 文档注释除外）
- 不添加多余空行/分隔符以外的格式化
- 领域模型分层：通用模型 → 业务适配 → 应用 UI
- JSON 键名小写蛇形，`board` 而非 `lists`
- 所有 fixture 同步维护两份：`src/studio/assets/fixtures/` 和 `assets/fixtures/`

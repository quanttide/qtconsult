# Changelog

## [Unreleased]

### Changed
- 引入 `go_router`（平台契约：Studio 统一用 go_router）：路由表 `lib/router.dart`，状态门用 `redirect` + `refreshListenable`（`/` 只渲染未就绪阶段、就绪后归一化到 `/:wid/:pid`，未知路径回 `/`）；新增 `ProjectScreen` 承接看板宿主与 URL 同步，`HomeScreen` 不再依赖看板，阶段占位抽出 `PhasePlaceholder`；Web 初始路由取 `Uri.base`（新增 6 个测试，共 51）
- 结构合并：取消 `packages/`（data-sources、qtconsult-project），代码并入 `lib/` 分层（models / states / views / screens / services），入口统一为 `lib/qtconsult_studio.dart`
- 引入 `bloc` / `flutter_bloc`：`ConsultState` 改为不可变状态，业务逻辑迁入 `ConsultCubit`；新增 `AppCubit` 承担数据加载与工作区切换，`main.dart` 拆出 `HomeScreen`
- 引入 `bloc_lint`：`analysis_options.yaml` 以列表 include 接入 `package:bloc_lint/recommended.yaml`，`bloc lint .` 纳入检查
- 引入 `environment_config`：`QTCONSULT_PROVIDER_URL` / `QTCONSULT_API_TOKEN` 构建前生成到 `lib/environment_config.dart`，替代 `--dart-define`（deploy.yml 同步）
- Web 缓存从 `dart:html` 迁移到 `package:web`
- `main.dart` 瘦身为纯入口：根组件与依赖装配移到 `app.dart`，缓存默认落点 `projectCache` 移入 `services/`
- `analysis_options.yaml` 新增文档规则（`public_member_api_docs` 等 7 条）与测试规则（`use_test_throws_matchers` 等 2 条），补齐全部公开成员 `///` 文档注释
- `lib/` 与 `test/` 统一通过 `dart format`
- 原包文档 `packages/qtconsult-project/doc/` 迁至 `doc/`
- 测试补齐：`AppCubit` 数据源优先级/回退/切换用例，workspace switcher 断言补全（45 个测试）

### Removed
- 空占位 `lib/models/ooda_data.dart`
- 死代码 `lib/screens/workspace_select_screen.dart`
- 失效的结构说明 `doc/packages.md` 与 `docs/dev/packages.md`

## [studio/v0.3.0] - 2026-05-12

### Changed
- 重构看板阶段命名：Observe/Orient/Act → Clarify/Research/Execute
- OodaState → ConsultState, OodaScreen → ConsultBoardScreen
- 统一卡片组件：删除 4 个独立 Column 和定制 Card，改用 SimpleCard
- 调研分析列合并：原 Orient（根因分析）并入 Research
- 数据加载直接走 fixture，绕过错位缓存
- 清理死代码：删除 board_card_title.dart、board_card_description.dart
- 列布局从独立 Widget 改为 StageColumn + content builder

### Added
- SimpleCard 公共卡片组件（title + description）
- fixture 加载测试覆盖

## [0.2.0] - 2026-05-08

### Added
- Workspace switcher: dropdown in AppBar to switch between workspaces.
- Offline fallback workspaces: workspace switcher works even without Provider.
- Recording script demo for workspace switching and card interactions.

### Changed
- Removed workspace selection page; app loads first project directly.
- `_switchWorkspace` refactored to async, handles both provider and fallback.

### Tests
- 41 tests, 95.3% line coverage.
- Models: copyWith, toJson/fromJson, status color/label functions.
- Services: ProviderService mock HTTP, flush with provider path.
- Widgets: OodaScreen with workspace switcher, WorkspaceSwitcher component.

## [0.1.0] - 2026-05-08

### Changed
- Studio can load project data from provider API via `QTCONSULT_PROVIDER_URL`.
- Card changes are flushed back to provider and cached locally as fallback.
- Cache service now has IO and Web implementations; Web uses localStorage.
- Added bundled fixture fallback for Flutter Web static deployments.

## [0.0.2] - 2026-05-07

### 变更
- 统一卡片模型：废除旧 `ObserveCard`、`InsightCard`、`StrategyCard`、`TaskCard`，合并为 `BoardCard`
- 数据源切换：废除 `ooda_data.json` 静态加载，改为本地缓存 `data/project.json`
- 新增 `CacheService`：读写本地缓存，支持离线独立调试
- 模型对齐 fixtures 结构：`Project` → `lists`（observe/orient/decide/act）

## [0.0.1] - 2026-05-06

### 新增
- 咨询服务看板：基于 OODA 循环的四栏布局（调研 · 分析 · 决策 · 执行）
- 调研栏：业务理想与现实状况左右并列，支持勾选确认
- 分析栏：洞察卡片聚合展示，支持聚类筛选与折叠
- 决策栏：方案对比与客户倾向选择
- 执行栏：任务追踪，含状态标签与进度条
- Linux 桌面端构建与运行脚本
- 自动录制演示视频脚本

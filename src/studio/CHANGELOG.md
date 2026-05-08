# Changelog

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

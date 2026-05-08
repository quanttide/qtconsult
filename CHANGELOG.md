# Changelog

## [0.1.0] - 2026-05-08

### Changed
- Provider S3-compatible configuration completed for Aliyun OSS endpoints and `platform/` archive prefix usage.
- Studio is wired to provider API with provider-first loading, local cache, and bundled fixture fallback.
- Board data read/write path now aligns on the unified project model for `provider/v0.1.0`, `studio/v0.1.0`, and `v0.1.0`.

## [0.0.4] - 2026-05-07

### 变更
- CI: upload_oss.py 替换为 aliyun CLI
- Studio 缓存路径改为环境变量 `QTCONSULT_STUDIO_CACHE_PATH`
- 加宽执行列（Act）宽度
- Provider 测试重写：结构化断言、认证/校验测试

### 修复
- 隐藏洞察卡片上游 ID 显示
- 修复 env var 名不匹配导致缓存加载失败
- Flutter 模型 Card 改名为 BoardCard 避免与 Material 冲突

### 发布
- provider/v0.0.3
- studio/v0.0.3

## [0.0.3] - 2026-05-07

### 新增
- Studio 本地缓存（CacheService）：废除静态 JSON 加载，支持离线调试
- Provider 数据持久化（app.storage）：写操作自动保存，重启不丢失
- 端到端测试：根目录 `tests/test_e2e.py` + `pyproject.toml` uv 配置
- OSS 存储设计方案文档

### 变更
- Flutter 模型统一为 BoardCard，对齐 fixtures 结构
- Provider Pydantic 模型加 extra='allow' 支持自定义字段，新增 CardPatch 部分更新
- PMD 项目计划重构为迭代

### 发布
- provider/v0.0.2：Storage 集成完成
- studio/v0.0.2：客户端改造完成

## [0.0.2] - 2026-05-07

### 新增
- Terraform 部署配置：阿里云 OSS + CDN 一键部署
- Python OSS 上传脚本：Flutter Web 构建产物自动发布
- FastAPI 后端服务（provider）：CRUD API、统一卡片模型、存储层抽象
- 领域模型需求分析文档：统一卡片 schema（title, description, category, types, tags, upstream）
- 样例数据：`assets/fixtures/project.json`

### 变更
- 重构 terraform 配置至 `manifests/terraform/`
- 重写技术架构文档为看板概念的需求分析文档

## [0.0.1] - 2026-05-06

### 新增
- 交互设计文档（IxD）：横向四栏 OODA 布局
- 数据需求文档（DRD）：四层数据模型定义
- 咨询服务看板原型：OODA 循环可视化
- Flutter Studio 客户端：四栏看板桌面应用
- Linux 构建与运行脚本
- 演示视频自动录制脚本

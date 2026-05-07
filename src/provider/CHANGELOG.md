# Changelog

## [0.0.1] - 2026-05-07

### 新增
- FastAPI 后端服务，基于看板卡片模型的 CRUD API
- 数据模型：统一卡片 schema（title, description, category, types, tags, date, assignee, upstream）
- 存储层抽象：支持本地文件系统（LocalStorage）和 S3（S3Storage）
- Token 鉴权：通过 `QTCONSULT_API_TOKEN` 环境变量控制
- 配置中心：集中管理 storage、data_dir、s3 等配置
- 单元测试：覆盖增查改删全流程
- 样例数据：`assets/fixtures/project.json`

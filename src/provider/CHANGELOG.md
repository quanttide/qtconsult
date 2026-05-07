# Changelog

## [0.0.3] - 2026-05-07

### 变更
- 重写测试：结构化断言、新增认证测试（无/错/正确 token）、校验测试（422）

## [0.0.2] - 2026-05-07

### 变更
- 集成 `app.storage`：写操作持久化到文件，重启不丢失
- Pydantic 模型加 `extra='allow'` 保留自定义字段
- 新增 `CardPatch` 模型支持部分更新
- `date` 字段改为 `str | CardDate | None` 兼容字符串和对象格式
- `types` 字段改为 `str | None` 对齐 fixtures
- 移除观察列子列表，扁平化为单层

### 修复
- 测试覆盖认证（无/错/正确 token）和校验（缺失字段 422）

## [0.0.1] - 2026-05-07

### 新增
- FastAPI 后端服务，基于看板卡片模型的 CRUD API
- 数据模型：统一卡片 schema（title, description, category, types, tags, date, assignee, upstream）
- 存储层抽象：支持本地文件系统（LocalStorage）和 S3（S3Storage）
- Token 鉴权：通过 `QTCONSULT_API_TOKEN` 环境变量控制
- 配置中心：集中管理 storage、data_dir、s3 等配置
- 单元测试：覆盖增查改删全流程
- 样例数据：`assets/fixtures/project.json`

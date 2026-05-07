# S3 运维指南

## 概述

本文档描述 qtconsult 应用在云端 S3 存储结构化数据（JSON、Parquet 等）时的运维策略，重点关注版本升级导致的数据结构变更处理。

## S3 存储架构

### 桶（Bucket）规划

| 环境 | Bucket 名称 | 用途 |
|------|-------------|------|
| 生产 | `qtconsult-prod-[region]-data` | 线上结构化数据 |
| 预发 | `qtconsult-staging-[region]-data` | 预发布验证 |
| 开发 | `qtconsult-dev-[region]-data` | 开发测试 |

### 目录结构

```
bucket/
├── v1/                          # 旧版本数据（只读）
│   ├── projects/
│   ├── reports/
│   └── schemas/                 # 该版本对应的 schema 快照
├── v2/                          # 当前版本数据
│   ├── projects/
│   ├── reports/
│   └── schemas/
├── migration/                   # 迁移脚本与日志
│   ├── v1-to-v2/
│   └── v2-to-v3/
└── shared/                      # 版本无关的共享数据
```

## 数据结构变更原则

### 1. 向前兼容（推荐）

新增字段必须可选的，旧字段不得删除或修改语义。

```jsonc
// ✅ 向前兼容：新增字段为 optional
{ "name": "foo", "version": 2, "description?" null }  // v1
{ "name": "foo", "version": 2, "description": "bar" }  // v2

// ❌ 破坏性变更：重命名字段
{ "user_name": "foo" }  // v1
{ "username": "foo" }   // v2 — 旧数据读取失败
```

### 2. 无法兼容时的处理流程

当必须进行破坏性变更时，遵循以下步骤：

#### 步骤一：评估与计划

1. 确认受影响的文件范围和数量
2. 评估迁移耗时（预估公式：`总文件数 × 平均处理时间 / 并发数`）
3. 确定停机窗口或在线迁移策略

#### 步骤二：编写迁移脚本

迁移脚本存放于 `s3-migrations/` 目录，格式：

```
s3-migrations/
├── {timestamp}_{from_version}_to_{to_version}/
│   ├── README.md       # 迁移说明与回滚方案
│   ├── migrate.py      # 正向迁移脚本
│   ├── rollback.py     # 回滚脚本
│   ├── validate.py     # 数据校验脚本
│   └── config.json     # 迁移配置
```

迁移脚本要求：

- **幂等性**：重复执行不会产生副作用
- **可中断续传**：支持断点续传，记录已处理文件列表到 `_progress.json`
- **限速**：支持 `--rate-limit` 参数控制 S3 请求 QPS
- **dry-run**：支持 `--dry-run` 预览影响范围

#### 步骤三：预发验证

1. 在 staging 环境执行完整迁移
2. 运行 `validate.py` 校验数据完整性
3. 执行应用端集成测试
4. 确认性能指标（迁移耗时、S3 请求量）

#### 步骤四：生产执行

```
# 1. 启用 S3 桶版本控制（如未启用）
aws s3api put-bucket-versioning \
  --bucket qtconsult-prod-[region]-data \
  --versioning-configuration Status=Enabled

# 2. 锁定旧版本目录为只读
aws s3api put-bucket-policy ...  # 拒绝写 v1/

# 3. 执行 dry-run 预览
python s3-migrations/v1-to-v2/migrate.py --dry-run

# 4. 执行正式迁移（建议低峰期）
python s3-migrations/v1-to-v2/migrate.py \
  --rate-limit 100 \
  --concurrency 4 \
  --log-file migration-$(date +%Y%m%d-%H%M%S).log

# 5. 执行数据校验
python s3-migrations/v1-to-v2/validate.py \
  --source-version v1 \
  --target-version v2

# 6. 切换应用读取指向新版本
```

## 回滚策略

### 方式一：S3 版本控制回滚

S3 对象版本控制开启后，可通过 `DeleteMarker` 恢复先前版本：

```
aws s3api list-object-versions --bucket my-bucket --prefix v2/
aws s3api delete-object --bucket my-bucket --key v2/... --version-id <DeleteMarkerVersionId>
```

### 方式二：回滚脚本

如果版本控制未开启或需批量回滚，使用 `rollback.py`：

```
python s3-migrations/v1-to-v2/rollback.py --batch-size 1000
```

### 方式三：应用层兜底

应用代码应保留对旧版本数据的读取能力至少 N 个版本：

```python
class DataReader:
    VERSIONS = {
        1: "v1",
        2: "v2",
    }

    def read(self, key: str, version: int | None = None):
        prefix = self.VERSIONS.get(version or LATEST)
        return self._read_from_s3(f"{prefix}/{key}")
```

## Schema 管理

### Schema 快照

每次发版前，将当前使用的 JSON Schema / Parquet schema 快照保存到 S3：

```
bucket/
├── v1/schemas/
│   ├── project.schema.json
│   └── report.schema.json
├── v2/schemas/
│   ├── project.schema.json
│   └── report.schema.json
```

### Schema Registry

在应用中维护 Schema Registry，用于：

1. **读取时校验**：读取数据时根据文件所在版本目录加载对应 schema 校验
2. **写入时转换**：写入时统一转换为最新版本格式
3. **兼容性检查**：CI 中自动检查 schema 变更是否向前兼容

```python
# CI 兼容性检查伪代码
def check_compatibility(old_schema, new_schema):
    assert is_backward_compatible(old_schema, new_schema), \
        "Schema change is NOT backward compatible!"
    assert is_forward_compatible(old_schema, new_schema), \
        "Schema change is NOT forward compatible!"
```

## 数据生命周期管理

### 冷数据迁移

```
# 将超过 90 天未访问的旧版本数据移至 Glacier
aws s3api put-bucket-lifecycle-configuration \
  --bucket qtconsult-prod-[region]-data \
  --lifecycle-configuration file://lifecycle.json
```

```json
{
  "Rules": [
    {
      "Id": "archive-old-versions",
      "Status": "Enabled",
      "Prefix": "",
      "Transitions": [
        {
          "Days": 90,
          "StorageClass": "GLACIER"
        }
      ],
      "NoncurrentVersionTransitions": [
        {
          "NoncurrentDays": 30,
          "StorageClass": "GLACIER"
        }
      ]
    }
  ]
}
```

### 过期清理

- 迁移完成并验证通过后，旧版本数据保留 **30 天** 后自动删除
- `_progress.json` 等临时文件保留 **7 天**

## 监控与告警

### 关键指标

| 指标 | 告警阈值 | 说明 |
|------|----------|------|
| `s3_migration_failure_count` | > 0 | 迁移任务失败 |
| `s3_migration_duration` | > 预估时间 × 2 | 迁移耗时异常 |
| `s3_validation_error_count` | > 0 | 数据校验不通过 |
| `s3_list_objects_latency` | > 500ms | S3 响应延迟 |

### 审计日志

所有 S3 数据变更操作（迁移、回滚、删除）记录到 `s3://qtconsult-prod-audit/`：

```json
{
  "timestamp": "2026-05-07T10:00:00Z",
  "operation": "migrate",
  "from_version": "v1",
  "to_version": "v2",
  "files_processed": 15000,
  "files_failed": 2,
  "operator": "deploy-bot"
}
```

## 版本升级检查清单

- [ ] 评估数据结构变更是否可向前兼容
- [ ] 如无法兼容，编写迁移脚本并放入 `s3-migrations/`
- [ ] 更新 Schema Registry 中的版本定义
- [ ] 保存当前 schema 快照到 `v{current}/schemas/`
- [ ] 在 staging 环境执行完整迁移与校验
- [ ] 确认回滚脚本可用
- [ ] 通知相关团队变更窗口
- [ ] 启用 S3 版本控制（如未启用）
- [ ] 执行生产迁移
- [ ] 校验生产数据完整性
- [ ] 更新应用配置指向新版本前缀
- [ ] 清理旧版迁移进度文件

# QtConsult Provider

看板后端数据服务。

## 技术栈

- Python 3.12+
- FastAPI
- uv

## 快速开始

```bash
uv sync
uv run uvicorn app.main:app --reload
```

## 配置

通过环境变量配置：

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `QTCONSULT_API_TOKEN` | API 鉴权 Token，空则不鉴权 | `""` |
| `QTCONSULT_STORAGE` | 存储后端：`local` 或 `s3` | `local` |
| `QTCONSULT_DATA_DIR` | 本地数据目录 | `data/` |
| `QTCONSULT_S3_BUCKET` | S3 存储桶 | `""` |
| `QTCONSULT_S3_PREFIX` | S3 路径前缀 | `""` |

## API

| 方法 | 路径 | 说明 | 鉴权 |
|------|------|------|------|
| GET | `/project` | 获取完整项目数据 | - |
| GET | `/project/lists/{name}` | 获取列表数据 | - |
| GET | `/project/cards/{id}` | 获取卡片 | - |
| POST | `/project/cards` | 创建卡片 | ✓ |
| PUT | `/project/cards/{id}` | 更新卡片 | ✓ |
| DELETE | `/project/cards/{id}` | 删除卡片 | ✓ |

POST 创建卡片需传 query 参数 `list_name`，Observe 列表需额外传 `sublist_name`。

## 测试

```bash
uv run --dev pytest
```

## 数据结构

数据来源为 `assets/fixtures/project.json`，按看板模型组织：

- **observe** — 调研卡片，按子列表（业务理想/技术现实）分组
- **orient** — 洞察卡片
- **decide** — 策略卡片
- **act** — 任务卡片

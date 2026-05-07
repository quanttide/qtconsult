# 项目计划

## 阶段一：统一数据模型

Flutter 端将 `ObserveCard`、`InsightCard`、`StrategyCard`、`TaskCard` 合并为统一的 `Card`，与 provider 对齐。

| Flutter 旧字段 | 新 Card 字段 | 说明 |
|---------------|-------------|------|
| `ObserveCard.title` | `title` | 统一 |
| `subtitle` + `body` | `description` | 合并 |
| `isIdeal` | `category` | `"ideal"` / `"reality"` |
| `cluster` | `types` | 字符串数组 |
| `evidences[{observeCardId}]` | `upstream` | 统一为 Card[] ID |
| `linkedStrategy` | `upstream` | 同上 |
| `source` / `date` / `assignee` / `status` / `progress` / `blockedReason` 等 | 自定义字段 | 按需保留 |

## 阶段二：Flutter 接入 provider

- 添加 `http` 包依赖
- 新建 `api_service.dart`：封装所有对 provider 的 HTTP 调用
- 替换 `OodaLoader.load()` 为 GET `/project`
- 写操作（增改删）调用 POST/PUT/DELETE `/project/cards`

### 环境切换

```
开发：provider → localhost:8000 → data/（本地文件）
生产：provider → api.example.com → S3
```

Flutter 端通过 `--dart-define API_BASE_URL=` 编译时注入地址。

## 阶段三：集成验证

- provider 加载 `assets/fixtures/project.json` 作为初始数据
- 启动方式：`cd src/provider && uv run uvicorn app.main:app --reload`
- Flutter 启动直连 provider 读取渲染
- 通过 provider CRUD 端点在 Flutter 中完成增删改操作
- 验证完整链路：Flutter → FastAPI → LocalStorage / S3

### 后续接入 storage

当前 main.py 硬编码加载 `assets/fixtures/project.json`，写操作仅改内存不持久化。后续集成 `app.storage` 模块：

- 启动时 `storage.load(project_id)` 从 `data_dir` 读取
- 写操作后 `storage.save()` 持久化
- 首次运行 seed：`cp assets/fixtures/project.json data/project.json`

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

## 阶段四：端到端测试

### 测试范围

覆盖完整链路：Flutter 操作 → HTTP 请求 → Provider API → 存储层 → 数据验证。

### 测试场景

| 编号 | 场景 | 步骤 | 断言 |
|------|------|------|------|
| E2E-1 | 加载项目 | Flutter 启动 → GET /project | 渲染 4 列看板，Observe 8 张卡片，Orient 4 张，Decide 2 张，Act 6 张 |
| E2E-2 | 创建卡片 | Flutter 新建调研卡 → POST /project/cards | Observe 列新增一张卡片 |
| E2E-3 | 更新卡片 | Flutter 编辑洞察卡片标题 → PUT /project/cards/{id} | 卡片标题更新 |
| E2E-4 | 删除卡片 | Flutter 删除策略卡片 → DELETE /project/cards/{id} | 卡片从看板消失，再次 GET 返回 404 |
| E2E-5 | 拒未授权写操作 | 不带 Token → PUT /project/cards/{id} | 返回 401 |
| E2E-6 | 添加标签 | Flutter 给卡片加标签 → PUT /project/cards/{id} | tags 字段更新 |
| E2E-7 | 跨列表引用 | Orient 卡片 upstream 引用 Observe 卡片 | GET /project/cards/{id} 返回正确的 upstream ID |

### 测试方式

- Provider 侧：现有的 `tests/test_api.py` 用 TestClient 模拟 HTTP 请求
- Flutter 侧：使用 `flutter test` + `MockClient`（http 包提供的 mock）拦截请求，验证 UI 渲染
- 全链路：部署 provider 到本地，Flutter 直连运行，手动验证

### 关键验证点

- `GET /project` 返回的 `lists` 结构是否正确
- `POST` 新增后 `GET` 能查到
- `PUT` 部分更新不会覆盖未传字段
- `DELETE` 重复删除返回 404
- 数据持久化：重启后数据不丢失（storage 集成后）

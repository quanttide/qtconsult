# 测试套件说明

## 测试层级

qtconsult 采用三层测试策略，覆盖从单测到端到端集成的完整验证。

| 层级 | 目录 | 框架 | 覆盖内容 | 数量 |
|------|------|--------|----------|------|
| Provider 单测 | `src/provider/tests/test_api.py` | pytest + TestClient | 路由、存储、认证、多 workspace 隔离 | 37 |
| Flutter 单测 | `src/studio/test/widget_test.dart` | flutter_test | Widget 渲染、OodaState、flush、缓存 | 9 |
| **E2E 集成** | `tests/test_workspace_e2e.py` | pytest + httpx + subprocess | 启动 Provider + HTTP 全链路验证 | **6** |

---

## E2E 测试设计

### 目标

验证 v0.2.0 Workspace 隔离的核心场景：
1. Provider 启动正常，workspace 正确加载
2. 两个 workspace 数据读写互不干扰
3. Token scope 机制生效（跨 workspace 写操作返回 403）

### 测试数据

`tests/fixtures/` 提供最小化的 workspace 测试数据，仅包含必要字段：

```json
// workspace0/e2e-project.json
{
  "name": "e2e-project",
  "title": "E2E 测试项目",
  "workspace_id": "workspace0",
  "lists": {
    "observe": [{"id": "e2e-o1", "title": "E2E 观察", "category": "ideal"}],
    "orient": [],
    "decide": [],
    "act": []
  }
}
```

### 测试场景

| 测试函数 | 场景 | 验证点 |
|----------|------|--------|
| `test_workspace_list` | 列出所有 workspace | `GET /workspaces` → 200，包含 workspace0 + workspace1 |
| `test_project_read` | 分别读取项目 | workspace0 → "E2E 测试项目"，workspace1 → 对应标题 |
| `test_data_isolation` | workspace0 创建卡片 | POST workspace0 成功，GET workspace1 返回 404 |
| `test_token_scope_correct` | 正确 scope token | `workspace1:secret` → POST workspace1 返回 201 |
| `test_token_scope_wrong` | 错误 scope token | `workspace0:secret` → POST workspace1 返回 403 |
| `test_old_routes_gone` | 旧路由已移除 | `/project`、`/project/lists/` 等返回 404 |

### 启动流程

1. 创建临时 `data/` 目录
2. 将 `fixtures/` 中的测试数据复制到临时目录
3. 启动 Provider 子进程，指向临时目录
4. 等待 Provider 就绪（轮询 `/workspaces`）
5. 执行 HTTP 验证
6. 终止 Provider，清理临时目录

---

## 运行方式

### 运行 E2E 测试

```bash
cd apps/qtconsult
uv run pytest tests/test_workspace_e2e.py -v
```

### 运行 Provider 单测

```bash
cd apps/qtconsult/src/provider
uv run pytest tests/test_api.py -v
```

### 运行 Flutter 单测

```bash
cd apps/qtconsult/src/studio
flutter test
```

---

## 覆盖范围总结

### ✅ 已覆盖

- Workspace 模型与路由（Provider 单测）
- Storage 两级路径与 list 方法
- 多 workspace 数据隔离
- Token scope 认证（`{wid}:{secret}` 格式）
- 旧路由 404 验证
- Flutter Widget 渲染（四栏布局）
- OodaState toggle、updateClientNote、flush
- 启动自迁移（legacy → workspace 结构）

### 📋 未覆盖（留给手动联调）

- Flutter Studio 实际启动 → workspace 选择 UI
- Flutter ProviderService HTTP 调用（需 mock 或真实 Provider）
- Flutter WorkspaceSelectScreen 渲染
- 真实浏览器环境 OAuth / SSO 集成
- 生产环境 S3 存储验证

---

## 手动联调清单

E2E 测试通过后，需在本地有 GUI 环境执行：

```bash
# 1. 启动 Provider
cd apps/qtconsult/src/provider
QTCONSULT_API_TOKEN=secret uv run uvicorn app.main:app --port 8543 &

# 2. 构建并运行 Flutter Studio
cd apps/qtconsult/src/studio
flutter run -d chrome  # 或 -d linux

# 3. UI 验证
#   - 看到 workspace 选择页，确认 workspace0 / workspace1 都在
#   - 点击 workspace1 → 进入 project1 看板，数据正确
#   - 返回 → 点击 workspace0 → 进入 project0 看板（量潮科技自我诊断）
#   - 在任一看板修改卡片 → 刷新另一个 workspace，确认互不影响

# 4. Token scope 验证
curl -X POST http://localhost:8543/workspaces/workspace1/projects/project1/cards \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer workspace0:secret" \
  -d '{"id":"x","title":"x"}'
# 应返回 403

# 5. 终止 Provider
kill %1
```

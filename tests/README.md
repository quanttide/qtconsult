# 测试文档

## 测试分层

| 层 | 位置 | 类型 | 覆盖范围 |
|:---|:-----|:-----|:---------|
| 单元测试 | `src/provider/tests/` | TestClient | Provider 内部逻辑 |
| 集成测试 | `tests/` | httpx + 真实 Provider | 服务端 API 契约 |

## 集成测试

覆盖 Provider API 的跨 workspace 业务场景。

| 业务实体 | 测试文件 | 覆盖场景 |
|:---------|:---------|:---------|
| **Workspace** | `test_workspace.py` | 多租户列取、项目读取、旧路由 404 |
| **Project** | `test_project.py` | OODA 卡片 CRUD、数据隔离 |
| **Auth** | `test_auth.py` | token scope、workspace 锁定、无 token 拒绝 |

```bash
uv run pytest tests/ -v
```

## 相关文档

| 文档 | 说明 |
|:-----|:-----|
| `docs/qa/index.md` | QA 总则 |
| `docs/qa/workspace.md` | 工作区测试用例 |
| `docs/qa/project.md` | 项目看板测试用例 |
| `docs/qa/permission.md` | 权限测试用例 |

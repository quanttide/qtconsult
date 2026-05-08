# 测试文档

## 测试分层

| 层 | 位置 | 类型 | 范围 |
|----|------|------|------|
| 单元测试 | `src/provider/tests/` | FastAPI TestClient | Provider 内部逻辑 |
| 集成测试 | `tests/` | httpx + 真实 Provider 进程 | 服务端 API 契约 |
| Web E2E | `tests/web/` | Playwright + 真实 Provider + Flutter Web | 浏览器端全链路 |
| Linux E2E | `tests/linux/` | xdotool + OCR + 真实 Provider + Flutter Linux | 桌面端全链路 |

## 集成测试

覆盖 Provider API 的跨 workspace 业务场景。

| 业务实体 | 测试文件 | 覆盖场景 |
|----------|----------|----------|
| **Workspace**（工作区） | `test_workspace.py` | 多租户列取、项目读取、旧路由 404 |
| **Project**（项目） | `test_project.py` | OODA 卡片 CRUD、数据隔离 |
| **Auth**（访问控制） | `test_auth.py` | token scope、workspace 锁定、无 token 拒绝 |

```bash
uv run pytest tests/ -v
```

## Web E2E 测试

Playwright 操控 Chromium，对 Flutter Web 做真实点击。

```bash
uv run pytest tests/web/ -v
```

详见 [tests/web/README.md](web/README.md)

## Linux Desktop E2E 测试

xdotool + OCR，对 Flutter Linux Desktop 做真实点击。

```bash
uv run pytest tests/linux/ -v
```

详见 [tests/linux/README.md](linux/README.md)

# 测试文档

## QA 用例到测试的映射

QA 文档定义业务验收标准，测试代码负责验证。以下映射说明每条 QA 用例由哪层测试覆盖。

| QA 用例 | 集成测试 | Web E2E | Linux E2E |
|:--------|:--------|:--------|:----------|
| TC-WS-001 查看工作区列表 | ✓ | ✓ | ✓ |
| TC-WS-002 展开工作区查看项目 | — | ✓ | ✓ |
| TC-WS-003 从工作区进入项目看板 | — | ✓ | ✓ |
| TC-WS-004 切换工作区 | — | ✓ | ✓ |
| TC-WS-005 工作区数据隔离 | ✓ | — | — |
| TC-WS-006 无工作区时的表现 | ✓ | — | — |
| TC-WS-007 加载失败时的表现 | — | ✓ | — |
| TC-PJ-001 查看 OODA 看板布局 | — | ✓ | ✓ |
| TC-PJ-002 查看 Observe 栏 | ✓ | ✓ | ✓ |
| TC-PJ-003 查看 Orient 栏 | ✓ | ✓ | ✓ |
| TC-PJ-004 查看 Decide 栏 | ✓ | ✓ | ✓ |
| TC-PJ-005 查看 Act 栏 | ✓ | ✓ | ✓ |
| TC-PJ-006 切换 Observe 确认状态 | ✓ | ✓ | ✓ |
| TC-PJ-007 切换 Decide 选中状态 | ✓ | ✓ | ✓ |
| TC-PJ-008 更新卡片备注 | ✓ | ✓ | ✓ |
| TC-PM-001~006 权限 | ✓* | — | — |

> ✓* 权限用例当前仅集成测试覆盖 token 级别的访问控制，完整的角色体系待账号系统上线

## 测试分层

| 层 | 位置 | 覆盖范围 |
|:---|:-----|:---------|
| 集成测试 | `tests/` | API 契约、数据隔离、认证鉴权 |
| Web E2E | `tests/web/` | 浏览器端用户操作全链路 |
| Linux E2E | `tests/linux/` | 桌面端用户操作全链路 |

## 集成测试

覆盖 Provider API 的跨 workspace 业务场景。

```bash
uv run pytest tests/ -v
uv run pytest tests/test_workspace.py -v
```

## Web E2E

Playwright 操控 Chromium，对 Flutter Web 做真实点击。

```bash
uv run pytest tests/web/ -v
```

详见 [tests/web/README.md](web/README.md)

## Linux Desktop E2E

xdotool + OCR，对 Flutter Linux Desktop 做真实点击。

```bash
uv run pytest tests/linux/ -v
```

详见 [tests/linux/README.md](linux/README.md)

## 相关文档

| 文档 | 说明 |
|:-----|:-----|
| `docs/qa/index.md` | QA 总则 |
| `docs/qa/workspace.md` | 工作区测试用例 |
| `docs/qa/project.md` | 项目看板测试用例 |
| `docs/qa/permission.md` | 权限测试用例 |

# Web E2E 测试

## 测试链条

```
pytest ──→ Provider(uvicorn:8756) + Flutter Web(web-server:8757) ──→ Playwright(Chromium) ──→ 真实浏览器点击
```

| 环节 | 技术 | 角色 |
|------|------|------|
| 编排 | pytest | 控制进程生命周期，断言测试结果 |
| 服务端 | FastAPI (uvicorn) | 真实 Provider 进程，端口 8756 |
| 客户端 | Flutter Web (HTML renderer) | 真实 Web 应用，端口 8757 |
| 自动化 | Playwright (Chromium) | 操控浏览器，模拟用户点击和输入 |

## 文件结构

```
tests/web/
├── README.md            # 本文件
├── conftest.py          # fixture：Provider 进程、Flutter Web 服务器、Playwright 浏览器、页面对象
├── test_workspace.py    # 工作区 E2E 场景
└── test_project.py      # 项目看板 E2E 场景
```

## 前置条件

```bash
# 1. 安装 Playwright 浏览器
playwright install chromium

# 2. 确认 Flutter 可用
flutter --version
```

## 运行

```bash
uv run pytest tests/web/ -v
uv run pytest tests/web/test_workspace.py -v
```

测试 fixtue 会自动：
1. 在临时目录写入测试数据
2. 启动 Provider 进程
3. 启动 Flutter Web 开发服务器
4. 打开 Chromium 浏览器
5. 执行用户操作场景
6. 清理所有进程

## 验证方式

通过 Playwright 定位页面文本元素，验证：
- 页面渲染了正确的业务文本（工作区名称、项目标题、卡片内容）
- 点击后页面正确导航
- 用户操作触发预期的 UI 变更

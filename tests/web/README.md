# Web E2E 测试

## 覆盖的 QA 用例

| QA 用例 | 测试文件 | 验证方式 |
|:--------|:---------|:---------|
| TC-WS-001 查看工作区列表 | `test_workspace.py` | Playwright 定位页面文本「选择工作区」和 workspace 名称 |
| TC-WS-002 展开工作区查看项目 | `test_workspace.py` | 点击 workspace 卡片，验证项目列表展开 |
| TC-WS-003 从工作区进入项目看板 | `test_workspace.py` | 点击项目名，验证跳转到看板页面 |
| TC-WS-004 切换工作区 | `test_workspace.py` | 返回列表，展开另一个 workspace，点击项目 |
| TC-WS-007 加载失败时的表现 | `test_workspace.py` | 不启动 Provider，验证 fallback 和提示 |
| TC-PJ-001 查看 OODA 看板布局 | `test_project.py` | 验证四栏标题和布局结构 |
| TC-PJ-002 查看 Observe 栏 | `test_project.py` | 验证卡片标题、分类和确认状态 |
| TC-PJ-003 查看 Orient 栏 | `test_project.py` | 验证洞察卡片及其聚类 |
| TC-PJ-004 查看 Decide 栏 | `test_project.py` | 验证策略卡片 |
| TC-PJ-005 查看 Act 栏 | `test_project.py` | 验证任务卡片和状态 |
| TC-PJ-006 切换 Observe 确认状态 | `test_project.py` | 点击确认按钮，验证 UI 状态变化 |
| TC-PJ-007 切换 Decide 选中状态 | `test_project.py` | 点击倾向按钮，验证高亮变化 |
| TC-PJ-008 更新卡片备注 | `test_project.py` | 输入备注文本，验证内容展示 |

## 测试链条

```
pytest ──→ Provider(uvicorn:8756) + Flutter Web(web-server:8757) ──→ Playwright(Chromium) ──→ 真实浏览器点击
```

| 环节 | 技术 | 角色 |
|:-----|:-----|:-----|
| 编排 | pytest | 控制进程生命周期，断言测试结果 |
| 服务端 | FastAPI (uvicorn) | 真实 Provider 进程，端口 8756 |
| 客户端 | Flutter Web (HTML renderer) | 真实 Web 应用，端口 8757 |
| 自动化 | Playwright (Chromium) | 操控浏览器，模拟用户点击和输入 |

## 文件结构

```
tests/web/
├── README.md            # 本文件
├── conftest.py          # fixture：Provider 进程、Flutter Web 服务器、Playwright 浏览器
├── test_workspace.py    # 工作区 E2E 场景
└── test_project.py      # 项目看板 E2E 场景
```

## 前置条件

```bash
playwright install chromium
flutter --version
```

## 运行

```bash
uv run pytest tests/web/ -v
uv run pytest tests/web/test_workspace.py -v
```

测试 fixture 会自动：
1. 写入测试数据到临时目录
2. 启动 Provider 进程
3. 启动 Flutter Web 开发服务器
4. 打开 Chromium 浏览器
5. 执行用户操作场景
6. 清理所有进程

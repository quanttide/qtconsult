# Linux Desktop E2E 测试

## 覆盖的 QA 用例

| QA 用例 | 测试文件 | 验证方式 |
|:--------|:---------|:---------|
| TC-WS-001 查看工作区列表 | `test_workspace.py` | 截屏 + OCR 识别「选择工作区」和 workspace 名称 |
| TC-WS-002 展开工作区查看项目 | `test_workspace.py` | 点击 workspace 卡片后二次截屏，识别项目名称 |
| TC-WS-003 从工作区进入项目看板 | `test_workspace.py` | 点击项目名后截屏，识别看板标题 |
| TC-WS-004 切换工作区 | `test_workspace.py` | 返回列表，操作另一个 workspace |
| TC-PJ-001 查看 OODA 看板布局 | `test_project.py` | 截屏识别四栏标题 |
| TC-PJ-002 查看 Observe 栏 | `test_project.py` | 截屏识别卡片标题 |
| TC-PJ-003 查看 Orient 栏 | `test_project.py` | 截屏识别洞察卡片 |
| TC-PJ-004 查看 Decide 栏 | `test_project.py` | 截屏识别策略卡片 |
| TC-PJ-005 查看 Act 栏 | `test_project.py` | 截屏识别任务卡片 |
| TC-PJ-006 切换 Observe 确认状态 | `test_project.py` | 点击确认按钮后截屏，识别状态变化 |
| TC-PJ-007 切换 Decide 选中状态 | `test_project.py` | 点击倾向按钮后截屏 |
| TC-PJ-008 更新卡片备注 | `test_project.py` | 输入文本后截屏识别 |

## 测试链条

```
pytest ──→ Provider(uvicorn:8756) + Flutter Linux(桌面进程)
         ──→ ImageMagick(截屏) → Tesseract OCR(文本识别) → xdotool(窗口搜索+鼠标点击)
```

| 环节 | 技术 | 角色 |
|:-----|:-----|:-----|
| 编排 | pytest | 控制进程生命周期，断言测试结果 |
| 服务端 | FastAPI (uvicorn) | 真实 Provider 进程，端口 8756 |
| 客户端 | Flutter Linux Desktop | 真实桌面应用进程 |
| 窗口定位 | xdotool | 按窗口标题搜索 Flutter 窗口、激活窗口 |
| 截屏 | ImageMagick (`import`) | 截取指定窗口内容为图片 |
| 文本识别 | Tesseract OCR (`chi_sim`) | 从截图中识别文本及其像素坐标 |
| 操作模拟 | xdotool | 根据 OCR 坐标执行鼠标点击 |

## 文件结构

```
tests/linux/
├── README.md            # 本文件
├── conftest.py          # fixture：Provider 进程、Flutter Linux 进程、OCR/点击辅助函数
├── test_workspace.py    # 工作区 E2E 场景
└── test_project.py      # 项目看板 E2E 场景
```

## 前置条件

```bash
sudo apt install xdotool imagemagick tesseract-ocr tesseract-ocr-chi-sim
flutter config --enable-linux-desktop
```

## 运行

```bash
uv run pytest tests/linux/ -v
uv run pytest tests/linux/test_workspace.py -v
```

测试 fixture 会自动：
1. 写入测试数据到临时目录
2. 启动 Provider 进程
3. 启动 Flutter Linux Desktop 进程
4. 等待窗口出现
5. 执行用户操作场景（截屏 → OCR → xdotool 点击）
6. 清理所有进程

## 注意事项

- OCR 依赖屏幕渲染质量，确保测试环境有可用的 X11 显示器（`$DISPLAY`）
- 中文识别需要 `chi_sim` 语言包
- 测试执行期间不要移动鼠标或切换窗口

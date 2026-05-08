# Linux Desktop E2E 测试

## 测试链条

```
pytest ──→ Provider(uvicorn:8756) + Flutter Linux(桌面进程)
         ──→ scrot(截屏) → tesseract(OCR识别文本坐标) → xdotool(搜索窗口、模拟鼠标点击)
```

| 环节 | 技术 | 角色 |
|------|------|------|
| 编排 | pytest | 控制进程生命周期，断言测试结果 |
| 服务端 | FastAPI (uvicorn) | 真实 Provider 进程，端口 8756 |
| 客户端 | Flutter Linux Desktop | 真实桌面应用进程 |
| 窗口定位 | xdotool | 按窗口标题搜索 Flutter 窗口、激活窗口、获取窗口几何信息 |
| 截屏 | ImageMagick (`import`) | 截取指定窗口的内容为图片 |
| 文本识别 | Tesseract OCR (`chi_sim`) | 从截图中识别文本及其像素坐标 |
| 操作模拟 | xdotool | 根据 OCR 返回的坐标，执行鼠标点击 |

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
# 1. 安装系统依赖
sudo apt install xdotool imagemagick tesseract-ocr tesseract-ocr-chi-sim

# 2. 确认 Flutter Linux Desktop 可用
flutter config --enable-linux-desktop
flutter --version
```

## 运行

```bash
uv run pytest tests/linux/ -v
uv run pytest tests/linux/test_workspace.py -v
```

测试 fixture 会自动：
1. 在临时目录写入测试数据
2. 启动 Provider 进程
3. 启动 Flutter Linux Desktop 进程
4. 等待窗口出现
5. 执行用户操作场景（截屏 → OCR 定位 → xdotool 点击）
6. 清理所有进程

## 验证方式

通过截屏 + OCR 识别页面文本，验证：
- 页面渲染了正确的业务文本（工作区名称、项目标题、卡片内容）
- 点击操作触发了预期页面切换
- 用户操作触发预期的 UI 变更

## 注意事项

- OCR 依赖屏幕渲染质量，确保测试环境有可用的 X11 显示器（$DISPLAY）
- 中文识别需要 `chi_sim` 语言包
- 测试执行期间不要移动鼠标或切换窗口

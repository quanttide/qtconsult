# QtConsult Studio

量潮咨询服务看板客户端。

## Provider 联调

数据加载优先级：

1. `QTCONSULT_PROVIDER_URL` 指向的 provider API。
2. 本地缓存。
3. 内置 `assets/fixtures/projects/project1.json` 示例数据。

桌面调试示例：

```bash
flutter run \
  --dart-define=QTCONSULT_PROVIDER_URL=http://localhost:8000 \
  --dart-define=QTCONSULT_API_TOKEN=dev-token
```

Web 构建也使用 `--dart-define` 注入 provider 地址，避免依赖 `dart:io` 环境变量。

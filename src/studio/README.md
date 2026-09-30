# QtConsult Studio

量潮咨询服务看板客户端。

## Provider 联调

数据加载优先级：

1. `QTCONSULT_PROVIDER_URL` 指向的 provider API。
2. 本地缓存。
3. 内置 `assets/fixtures/workspace*/` 示例数据。

配置由 `environment_config` 在构建前生成到 `lib/environment_config.dart`：

```bash
QTCONSULT_PROVIDER_URL=http://localhost:8000 \
QTCONSULT_API_TOKEN=dev-token \
dart run environment_config:generate

flutter run -d chrome
```

未执行生成时使用仓库内默认值（空 → 走 fixture）。CI 在构建前执行同一命令注入 `vars.QTCONSULT_PROVIDER_URL`。

## 代码检查

```bash
flutter analyze   # Dart 静态检查（含 flutter_lints + 文档/测试规则）
bloc lint .       # Bloc 规则检查（需 dart pub global activate bloc_tools）
flutter test
```

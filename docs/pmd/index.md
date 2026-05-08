# 项目计划

## 当前迭代

Flutter 组件测试和集成测试覆盖。

### 待完成

| 事项 | 优先级 |
|:-----|:-------|
| WorkspaceSwitcher widget 测试 | 高 |
| 更新 OodaScreen widget 测试（含 AppBar 切换器） | 高 |
| ProviderService 集成测试（mock HTTP client） | 高 |
| _AppBody 工作区切换逻辑测试 | 高 |

## 数据结构契约（v0.2.0）

```json
{
  "name": "project1",
  "title": "商家赋能平台数字化转型",
  "workspace_id": "workspace1",
  "lists": {
    "observe": [{ "id": "o1", ... }],
    "orient": [{ "id": "i1", ..., "types": "..." }],
    "decide": [{ "id": "s1", ..., "isSelected": true }],
    "act":    [{ "id": "t1", ..., "status": "doing", "progress": 0.6 }]
  }
}
```

## v0.2.0 发布条件

- Provider + Studio 联调通过 workspace 切换全链路
- 两个 workspace 数据读写各自独立互不干扰
- Flutter 组件测试和集成测试通过
- QA 文档用例验收通过

# 项目计划

## v0.2.x — 前后端全链路联调

0.2.0 已完成 Provider API 和 Studio 的基础 workspace 切换，但前后端联调验证尚未完成，需要继续补全。

### 已发布

| 组件 | 版本 | 状态 |
|:-----|:-----|:-----|
| Provider | v0.2.0 | 64 测试，79% 覆盖率 |
| Studio | v0.2.0 | 41 测试，95% 覆盖率 |

### 待完成（v0.2.x）

| 事项 | 优先级 |
|:-----|:-------|
| Provider → Studio 全链路联调 | 高 |
| E2E 自动化验证方案落地 | 中 |
| 剩余 21% Provider 覆盖率（S3/启动迁移） | 低 |

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

## v0.2.x 发布条件

- Provider + Studio 全链路联调通过
- 两个 workspace 数据读写各自独立互不干扰
- Flutter 测试和 Provider 测试全绿
- QA 文档用例验收通过（workspace / project / permission）

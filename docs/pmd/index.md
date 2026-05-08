# 项目计划

## v0.2.0 状态

Workspace 隔离已完成，重新设计工作区切换 UI。

### 已完成

- Provider 多 workspace API（列取、隔离、认证 scope）
- 移除 workspace 选择独立页面，改为顶栏下拉切换
- 应用启动后直接加载第一个工作区项目进入看板
- QA 文档覆盖 workspace / project / permission 三份用例

### 待完成

| 事项 | 优先级 |
|:-----|:-------|
| 全链路联调验证 | 高 |
| v0.2.0 发布 | 高 |

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
- OA 文档用例验收通过

# 项目计划

v0.2.0 Workspace 隔离已完成开发，待全链路联调验证后发布。

---

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

## 开发同步脚本（v0.2.0）

```bash
cp assets/fixtures/workspace1/project1.json src/provider/data/workspace1/project1.json
cp assets/fixtures/workspace0/project0.json src/provider/data/workspace0/project0.json
```

## v0.2.0 发布条件

Provider + Studio 联调通过 workspace 切换全链路，两个 workspace 数据读写各自独立互不干扰。

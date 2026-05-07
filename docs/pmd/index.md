# 项目计划

## 迭代一：客户端缓存 + 数据结构对齐

**目标**：Flutter 端读取本地缓存数据，废除 `ooda_data.json`，对齐 fixtures 数据结构。

| 任务 | 说明 |
|------|------|
| 1.1 | 删除 `ooda_data.json` 和 `OodaLoader` 旧逻辑 |
| 1.2 | Flutter 模型类改为匹配 fixtures 结构（统一 Card、ProjectLists、OODA 列表键名） |
| 1.3 | 新建 `cache_service.dart`：从 `src/studio/data/` 读写 |
| 1.4 | 改造 `OodaState`：启动时读缓存渲染，无缓存时提示同步 |
| 1.5 | Fixtures 同步脚本：`assets/fixtures/projects/` → `src/studio/data/` |

**验证**：Flutter 独立启动，读取本地缓存正常渲染看板。

---

## 迭代二：服务端 storage 集成

**目标**：Provider 写操作持久化到文件，重启不丢失。

| 任务 | 说明 |
|------|------|
| 2.1 | main.py 集成 `app.storage`：启动时 `storage.load()`，写操作后 `storage.save()` |
| 2.2 | seed 脚本：首次运行时 `cp assets/fixtures/projects/ → data/` |
| 2.3 | Fixtures 同步脚本补充：`assets/fixtures/projects/` → `src/provider/data/` |

**验证**：Flutter 增删改后重启 provider，数据保留。

---

## 迭代三：HTTP API 接入

**目标**：Flutter 接入 provider API，增删改操作走服务端。

| 任务 | 说明 |
|------|------|
| 3.1 | 添加 `http` 包依赖 |
| 3.2 | 新建 `api_service.dart`：`fetchProject()`、`createCard()`、`updateCard()`、`deleteCard()` |
| 3.3 | 改造 `OodaState`：读缓存优先，提供"从服务端刷新"按钮调 API 更新缓存 |
| 3.4 | 写操作先调 API，成功后同步更新缓存 |
| 3.5 | `--dart-define API_BASE_URL=` 编译时注入后端地址 |

**验证**：启动 provider → Flutter 从 API 加载 → 增删改操作同步到缓存。

---

## 迭代四：端到端测试

| 任务 | 说明 |
|------|------|
| 4.1 | Provider 侧：TestClient 覆盖 CRUD + 边界（已实现） |
| 4.2 | Flutter 侧：MockClient 拦截请求，验证 UI 渲染 |
| 4.3 | 全链路：本地部署 provider + Flutter 直连，手动验证 7 个 E2E 场景 |

---

## 迭代五：生产部署

| 任务 | 说明 |
|------|------|
| 5.1 | Provider 部署 + S3 存储接入 |
| 5.2 | CI/CD 中配置 `API_BASE_URL` 指向生产地址 |
| 5.3 | 移除 fixtures 临时数据源，切换为正式数据 |

---

## 数据结构契约

Fixtures JSON 结构是服务端和客户端的共享契约：

```json
{
  "name": "project1",
  "title": "商家赋能平台数字化转型",
  "lists": {
    "observe": [{ "id": "o1", "title": "战略转型 · 商家赋能", "category": "ideal", ... }],
    "orient": [{ "id": "i1", "title": "...", "types": "战略技术断层", "upstream": ["o1", ...], ... }],
    "decide": [{ "id": "s1", "title": "方案A：...", "upstream": ["i1", ...], ... }],
    "act":    [{ "id": "t1", "title": "架构优化...", "upstream": ["s1"], ... }]
  }
}
```

## 开发同步脚本

每次 fixtures 变更后：

```bash
# 复制到客户端缓存（迭代一）
cp assets/fixtures/projects/project1.json src/studio/data/project.json

# 复制到服务端数据目录（迭代二）
cp assets/fixtures/projects/project1.json src/provider/data/project.json
```

## 版本发布

| 子模块 | v0.0.1 | v0.0.2 发布时机 |
|--------|--------|----------------|
| **studio** | 已发布 | 客户端改造完成（迭代一 + 迭代三） |
| **provider** | 已发布 | Storage 集成完成（迭代二） |

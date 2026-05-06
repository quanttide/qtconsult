# 数据需求文档

## 咨询服务看板

### 数据来源

看板客户端当前从 `assets/ooda_data.json` 加载模拟数据，后端就绪后通过 API 返回同构 JSON。

### 数据模型

#### 顶层结构：OodaData

```json
{
  "observes":   [ObserveCard, ...],
  "insights":   [InsightCard, ...],
  "strategies": [StrategyCard, ...],
  "tasks":      [TaskCard, ...]
}
```

#### 调研卡：ObserveCard

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | string | 是 | 唯一标识 |
| `title` | string | 是 | 卡片标题，建议 ≤ 8 字 |
| `subtitle` | string | 否 | 副标题 |
| `body` | string | 是 | 正文，建议 ≤ 2 行 |
| `source` | string | 是 | 来源描述，如"模拟访谈 · 5月15日" |
| `date` | string | 是 | 日期，如"5月15日" |
| `status` | "pending" / "confirmed" | 是 | 确认状态 |
| `isIdeal` | boolean | 是 | true=业务理想，false=现实状况 |

业务理想与现实状况通过 `isIdeal` 区分，客户端按此分组并列展示。

#### 洞察卡：InsightCard

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | string | 是 | 唯一标识 |
| `title` | string | 是 | 洞察标题 |
| `evidences` | [Evidence, ...] | 否 | 证据链接列表 |
| `rootCause` | string | 是 | 根因，建议 1 行 |
| `impact` | string | 是 | 影响，建议 1 行 |
| `cluster` | string | 是 | 聚类标签，用于分组筛选 |

Evidence：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `label` | string | 是 | 显示文本 |
| `observeCardId` | string | 是 | 关联的调研卡 ID |

#### 策略卡：StrategyCard

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | string | 是 | 唯一标识 |
| `name` | string | 是 | 方案名称 |
| `priority` | string | 否 | 优先级，如"P1" |
| `linkedInsightCount` | integer | 否 | 关联洞察数 |
| `advantage` | string | 是 | 优势描述 |
| `summary` | string | 是 | 方案概要 |
| `resources` | string | 是 | 资源与价格描述 |
| `keyAssumption` | string | 否 | 关键假设 |
| `isSelected` | boolean | 否 | 客户是否倾向本方案 |
| `clientNote` | string | 否 | 客户填写的顾虑或条件 |

#### 任务卡：TaskCard

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | string | 是 | 唯一标识 |
| `name` | string | 是 | 任务名称 |
| `status` | "todo"/"doing"/"done"/"blocked" | 是 | 状态枚举 |
| `linkedStrategy` | string | 否 | 关联策略标签 |
| `assignee` | string | 否 | 负责人 |
| `startDate` | string | 否 | 开始日期 |
| `endDate` | string | 否 | 截止日期 |
| `notes` | string | 否 | 备注 |
| `blockedReason` | string | 否 | 受阻原因 |
| `progress` | number | 否 | 进度 0.0-1.0 |

### 状态枚举

```
CardStatus: pending → confirmed
TaskStatus: todo → doing → done | blocked
```

### 关联关系

```
调研卡 ← 证据链接 → 洞察卡
洞察卡 ← 聚类 → 聚簇分组
策略卡 ← 关联 → 任务卡
```

### 当前数据量

| 实体 | 数量 |
|------|------|
| 调研卡 | 8 条（理想 4 + 现实 4） |
| 洞察卡 | 4 条（2 个聚簇） |
| 策略卡 | 2 套方案 |
| 任务卡 | 6 项任务 |

# BoardCard 卡片统一

## 问题

Observe / Orient / Decide / Act 四列各有一套私有卡片实现，同样容器结构（边框、圆角、间距）写了四遍。

## 目标

一个统一 `BoardCard`，覆盖所有卡片的视觉差异。

## 需要确认

1. **accentColor（左侧色条）** — 只有 Observe 列用，要不要进通用组件？
2. **InkWell 水波纹** — 当前卡片都没有点击交互，要不要？
3. **命名冲突** — `BoardCard` widget 与 domain model（数据类）同名，如何区分？

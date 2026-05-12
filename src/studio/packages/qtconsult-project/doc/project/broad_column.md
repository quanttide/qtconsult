# BoardColumn 分解方案

## 问题

`BoardColumn` 混合了三层职责：

1. **壳** — 白色圆角容器 + 阴影
2. **标题栏结构** — Row + icon + title + Spacer + subtitle 的排列
3. **具体内容假设** — icon 是 Widget、title 是 String、subtitle 是 String

如果一个组件编码了对内容的假设，它就不能放在基础库。`BoardColumn` 当前在 `qtconsult-project`（业务包），待稳定后**提炼并沉淀**到 `quanttide-project-toolkit`（基础库）。方向是自下而上的提取，而非先在基础库定义再被业务调用。

## 原则

基础库编码结构，不编码内容假设。任何业务特定的排列都不应出现在通用库中。

## 分解后

`BoardColumn` 只做壳：

```dart
class BoardColumn extends StatelessWidget {
  final Widget title;    // 标题栏插槽
  final Widget content;   // 内容插槽

  // 内部：白框 + 阴影 + title + Expanded(content)
  // 不假设 title 里面有什么
}
```

调用方自己组合 header：

```dart
BoardColumn(
  title: Row(children: [
    const Icon(Icons.search_outlined, size: 16, color: Color(0xFF333333)),
    const SizedBox(width: 8),
    const Flexible(
      child: Text('调研 · Observe',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
    ),
    const Spacer(),
    Flexible(
      child: Text('8 条',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, color: Color(0xFF999999))),
    ),
  ]),
  content: _Body(...),
)
```

## 业务层封装

如果每个 Column 都写一遍 Row + icon + Text 太重复，在业务包 `qtconsult-project` 内封装 `BoardColumnTitle`：

```dart
class BoardColumnTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String count;

  const BoardColumnTitle({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: Color(0xFF333333)),
      const SizedBox(width: 8),
      Flexible(
        child: Text(title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
      ),
      const Spacer(),
      Flexible(
        child: Text(count,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
      ),
    ]);
  }
}
```

BoardColumn 的 `title` 插槽中传入 `BoardColumnTitle`：

```dart
BoardColumn(
  title: BoardColumnTitle(
    icon: Icons.search_outlined,
    title: '调研 · Observe',
    count: '8 条',
  ),
  content: _Body(...),
)
```

## 层次关系

```
稳定后（提炼到基础库，业务包依赖基础库）
  quanttide-project-toolkit
    └─ BoardColumn: 壳（title + content 插槽）
  qtconsult-project
    └─ BoardColumnTitle: 图标 + 标题 + 计数封装
    └─ ObserveColumn / OrientColumn / DecideColumn / ActColumn
         └─ 使用 BoardColumn + BoardColumnTitle + 具体 content
```

先跑通、再稳定、最后才提到基础库。不提前做抽象。BoardColumn 是否值得进基础库，取决于 qtconsult 之外是否出现第二个业务包使用它。

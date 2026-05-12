import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:data_sources/cache_service.dart';
import 'package:data_sources/provider_service.dart';
import 'package:qtconsult_project/qtconsult_project.dart';

List<Task> makeTestTasks() {
  return [
    Task(id: 'o1', title: '调研卡片', description: '测试描述', type: 'observe', category: 'ideal',
        tags: {'source': '访谈'}, status: 'pending'),
    Task(id: 'o2', title: '现实卡片', type: 'observe', category: 'reality',
        tags: {'source': '审计'}, status: 'confirmed'),
    Task(id: 'i1', title: '洞察测试', type: 'orient',
        tags: {'domain': '技术领域', 'rootCause': '根因', 'impact': '影响'}),
    Task(id: 's1', title: '方案A', type: 'decide',
        tags: {'advantage': '优势', 'isSelected': 'true'}),
    Task(id: 't1', title: '任务1', type: 'act', assignee: '某人', status: 'doing',
        tags: {'progress': '0.5'}),
  ];
}

List<WorkspaceInfo> makeWorkspaces() {
  return [
    const WorkspaceInfo(id: 'ws1', name: '工作区A', projectIds: ['test']),
    const WorkspaceInfo(id: 'ws2', name: '工作区B', projectIds: ['p2']),
  ];
}

Widget buildApp(List<Task> tasks,
    {List<WorkspaceInfo>? workspaces,
    String currentWsId = '',
    void Function(String)? onSwitch,
    String? loadWarning}) {
  return ChangeNotifierProvider(
    create: (_) => OodaState(tasks, CacheService(filePath: '')),
    child: MaterialApp(
      home: OodaScreen(
        workspaces: workspaces,
        currentWsId: currentWsId,
        onSwitchWorkspace: onSwitch,
        loadWarning: loadWarning,
      ),
    ),
  );
}

void main() {
  testWidgets('看板渲染卡片', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildApp(makeTestTasks()));

    expect(find.text('咨询服务看板'), findsOneWidget);
    expect(find.text('调研卡片'), findsOneWidget);
    expect(find.text('洞察测试'), findsOneWidget);
    expect(find.text('方案A'), findsOneWidget);
    expect(find.text('任务1'), findsOneWidget);
  });

  testWidgets('有工作区时显示切换器', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildApp(makeTestTasks(),
        workspaces: makeWorkspaces(),
        currentWsId: 'ws1',
        onSwitch: (_) {}));

    expect(find.text('工作区A'), findsOneWidget);
  });

  testWidgets('无工作区时不显示切换器', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildApp(makeTestTasks(),
        onSwitch: (_) {}));

    expect(find.byIcon(Icons.workspaces_outlined), findsNothing);
  });

  testWidgets('切换工作区触发回调', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    String? selected;
    await tester.pumpWidget(buildApp(makeTestTasks(),
        workspaces: makeWorkspaces(),
        currentWsId: 'ws1',
        onSwitch: (wid) => selected = wid));

    await tester.tap(find.byIcon(Icons.workspaces_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('工作区B'));
    await tester.pumpAndSettle();
    expect(selected, 'ws2');
  });

  testWidgets('渲染加载警告', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildApp(makeTestTasks(),
        loadWarning: 'Provider 不可用，使用缓存数据'));

    expect(find.text('Provider 不可用，使用缓存数据'), findsOneWidget);
  });
}

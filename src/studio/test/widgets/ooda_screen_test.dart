import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qtconsult_studio/models/ooda_data.dart';
import 'package:qtconsult_studio/screens/ooda_screen.dart';
import 'package:qtconsult_studio/services/ooda_state.dart';
import 'package:qtconsult_studio/services/cache_service.dart';
import 'package:qtconsult_studio/services/provider_service.dart';

Project makeTestProject() {
  return Project(
    name: 'test',
    title: '测试项目',
    lists: ProjectLists(
      observe: [
        BoardCard(id: 'o1', title: '调研卡片', description: '测试描述', category: 'ideal',
            custom: {'status': 'pending', 'source': '访谈'}),
        BoardCard(id: 'o2', title: '现实卡片', category: 'reality',
            custom: {'status': 'confirmed', 'source': '审计'}),
      ],
      orient: [
        BoardCard(id: 'i1', title: '洞察测试', types: '技术领域',
            upstream: ['o1'], custom: {'rootCause': '根因', 'impact': '影响'}),
      ],
      decide: [
        BoardCard(id: 's1', title: '方案A', upstream: ['i1'],
            custom: {'advantage': '优势', 'isSelected': true}),
      ],
      act: [
        BoardCard(id: 't1', title: '任务1', assignee: '某人',
            custom: {'status': 'doing', 'progress': 0.5}),
      ],
    ),
  );
}

List<WorkspaceInfo> makeWorkspaces() {
  return [
    const WorkspaceInfo(id: 'ws1', name: '工作区A', projectIds: ['test']),
    const WorkspaceInfo(id: 'ws2', name: '工作区B', projectIds: ['p2']),
  ];
}

Widget buildApp(Project project,
    {List<WorkspaceInfo>? workspaces,
    String currentWsId = '',
    void Function(String)? onSwitch,
    String? loadWarning}) {
  return ChangeNotifierProvider(
    create: (_) => OodaState(project, CacheService(filePath: '')),
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

    await tester.pumpWidget(buildApp(makeTestProject()));

    expect(find.text('咨询服务看板'), findsOneWidget);
    expect(find.text('调研卡片'), findsOneWidget);
    expect(find.text('洞察测试'), findsOneWidget);
    expect(find.text('方案A'), findsOneWidget);
    expect(find.text('任务1'), findsOneWidget);
  });

  testWidgets('有工作区时显示切换器', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildApp(makeTestProject(),
        workspaces: makeWorkspaces(),
        currentWsId: 'ws1',
        onSwitch: (_) {}));

    expect(find.text('工作区A'), findsOneWidget);
  });

  testWidgets('无工作区时不显示切换器', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildApp(makeTestProject(),
        onSwitch: (_) {}));

    expect(find.byIcon(Icons.workspaces_outlined), findsNothing);
  });

  testWidgets('切换工作区触发回调', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    String? selected;
    await tester.pumpWidget(buildApp(makeTestProject(),
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

    await tester.pumpWidget(buildApp(makeTestProject(),
        loadWarning: 'Provider 不可用，使用缓存数据'));

    expect(find.text('Provider 不可用，使用缓存数据'), findsOneWidget);
  });


}

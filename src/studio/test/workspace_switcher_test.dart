import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtconsult_studio/services/provider_service.dart';
import 'package:qtconsult_studio/widgets/workspace_switcher.dart';

List<WorkspaceInfo> makeWorkspaces() {
  return [
    const WorkspaceInfo(id: 'ws1', name: '工作区A', projectIds: ['p1']),
    const WorkspaceInfo(id: 'ws2', name: '工作区B', projectIds: ['p2']),
    const WorkspaceInfo(id: 'ws3', name: '工作区C', projectIds: ['p3']),
  ];
}

Widget buildApp(WorkspaceSwitcher widget) {
  return MaterialApp(home: Scaffold(body: widget));
}

void main() {
  testWidgets('显示当前工作区名称', (tester) async {
    String? selected;
    await tester.pumpWidget(buildApp(WorkspaceSwitcher(
      workspaces: makeWorkspaces(),
      currentWsId: 'ws1',
      onSwitch: (wid) => selected = wid,
    )));
    expect(find.text('工作区A'), findsOneWidget);
  });

  testWidgets('下拉列出其他工作区', (tester) async {
    String? selected;
    await tester.pumpWidget(buildApp(WorkspaceSwitcher(
      workspaces: makeWorkspaces(),
      currentWsId: 'ws1',
      onSwitch: (wid) => selected = wid,
    )));
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('工作区B'), findsOneWidget);
    expect(find.text('工作区C'), findsOneWidget);
  });

  testWidgets('当前工作区不显示在下拉中', (tester) async {
    String? selected;
    await tester.pumpWidget(buildApp(WorkspaceSwitcher(
      workspaces: makeWorkspaces(),
      currentWsId: 'ws1',
      onSwitch: (wid) => selected = wid,
    )));
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('工作区A'), findsOneWidget);
    expect(find.text('工作区B'), findsOneWidget);
    expect(find.text('工作区C'), findsOneWidget);
  });

  testWidgets('选择工作区触发回调', (tester) async {
    String? selected;
    await tester.pumpWidget(buildApp(WorkspaceSwitcher(
      workspaces: makeWorkspaces(),
      currentWsId: 'ws1',
      onSwitch: (wid) => selected = wid,
    )));
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('工作区B').last);
    await tester.pumpAndSettle();
    expect(selected, 'ws2');
  });
}

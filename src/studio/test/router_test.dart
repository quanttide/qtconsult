import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qtconsult_studio/qtconsult_studio.dart';
import 'package:qtconsult_studio/router.dart';
import 'package:qtconsult_studio/screens/home_screen.dart';

Future<String> _fileAsset(String path) async => File(path).readAsStringSync();

CacheService _cacheFor(String wid, String pid) => CacheService(filePath: '');

AppCubit _cubit({({String wid, String pid})? initialTarget}) {
  return AppCubit(
    cacheBuilder: _cacheFor,
    loadAsset: _fileAsset,
    initialTarget: initialTarget,
  )..load();
}

Future<void> _pumpApp(
  WidgetTester tester,
  String location,
  AppCubit cubit,
) async {
  await tester.binding.setSurfaceSize(const Size(1200, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    BlocProvider<AppCubit>(
      create: (_) => cubit,
      child: MaterialApp.router(
        routerConfig: buildRouter(initialLocation: location),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('/ 默认加载首个项目', (tester) async {
    await _pumpApp(tester, '/', _cubit());

    expect(find.text('咨询看板'), findsOneWidget);
    expect(find.text('工作区 0'), findsOneWidget);
  });

  testWidgets('深链 /:wid/:pid 经 initialTarget 直达目标', (tester) async {
    await _pumpApp(
      tester,
      '/workspace1/project1',
      _cubit(initialTarget: (wid: 'workspace1', pid: 'project1')),
    );

    expect(find.text('工作区 1'), findsOneWidget);
  });

  testWidgets('深链无 initialTarget 时经状态同步收敛', (tester) async {
    await _pumpApp(tester, '/workspace1/project1', _cubit());

    expect(find.text('工作区 1'), findsOneWidget);
  });

  testWidgets('未知路径回落首页', (tester) async {
    await _pumpApp(tester, '/random', _cubit());

    expect(find.text('咨询看板'), findsOneWidget);
    expect(find.text('工作区 0'), findsOneWidget);
  });

  testWidgets('站内切换工作区改写路由', (tester) async {
    await _pumpApp(tester, '/', _cubit());

    await tester.tap(find.byIcon(Icons.workspaces_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('工作区 1'));
    await tester.pumpAndSettle();

    expect(find.text('工作区 1'), findsOneWidget);
    final router = GoRouter.of(tester.element(find.byType(HomeScreen)));
    expect(router.state.uri.path, '/workspace1/project1');
  });
}

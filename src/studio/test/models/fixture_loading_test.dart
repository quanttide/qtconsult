import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qtconsult_project/qtconsult_project.dart';

void main() {
  test('load fixture workspace0/project0.json', () {
    final raw = File('assets/fixtures/workspace0/project0.json').readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;

    final project = Project.fromJson(json);
    expect(project.name, 'project0');
    expect(project.title, '量潮科技自我诊断');

    final tasks = (json['tasks'] as List)
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
    expect(tasks.length, 18);
    expect(tasks.where((t) => t.type == 'observe-ideal' || t.type == 'observe-reality').length, 6);
    expect(tasks.where((t) => t.type == 'orient').length, 4);
    expect(tasks.where((t) => t.type == 'decide').length, 2);
    expect(tasks.where((t) => t.type == 'act').length, 6);
  });

  test('load fixture workspace1/project1.json', () {
    final raw = File('assets/fixtures/workspace1/project1.json').readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;

    final project = Project.fromJson(json);
    expect(project.name, 'project1');
    expect(project.title, '商家赋能平台数字化转型');

    final tasks = (json['tasks'] as List)
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
    expect(tasks.length, 20);
    expect(tasks.where((t) => t.type == 'observe-ideal' || t.type == 'observe-reality').length, 8);
    expect(tasks.where((t) => t.type == 'orient').length, 4);
    expect(tasks.where((t) => t.type == 'decide').length, 2);
    expect(tasks.where((t) => t.type == 'act').length, 6);
  });
}

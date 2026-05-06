import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:qtconsult_studio/models/ooda_data.dart';

class OodaLoader {
  static Future<OodaData> load() async {
    final jsonString = await rootBundle.loadString('assets/ooda_data.json');
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return OodaData.fromJson(json);
  }
}

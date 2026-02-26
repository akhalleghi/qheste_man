import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/finance_items.dart';

class CheckStorage {
  static const _checksKey = 'saved_checks_v1';

  static Future<List<CheckItem>> loadChecks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_checksKey);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => CheckItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveChecks(List<CheckItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_checksKey, encoded);
  }
}


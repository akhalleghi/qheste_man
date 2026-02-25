import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/finance_items.dart';

class InstallmentStorage {
  static const _installmentsKey = 'saved_installments_v1';

  static Future<List<InstallmentItem>> loadInstallments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_installmentsKey);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => InstallmentItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveInstallments(List<InstallmentItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_installmentsKey, encoded);
  }
}

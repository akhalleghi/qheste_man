import 'package:flutter/cupertino.dart';

class AppColors {
  static const Color primary = Color(0xFF007AFF);
  static const Color checksAccent = Color(0xFF30B28C);

  static bool isDark(BuildContext context) {
    return CupertinoTheme.brightnessOf(context) == Brightness.dark;
  }

  static Color background(BuildContext context) {
    return isDark(context) ? const Color(0xFF0B0B0F) : const Color(0xFFF2F2F7);
  }

  static Color sectionBackground(BuildContext context) {
    return isDark(context) ? const Color(0xFF1C1C1E) : CupertinoColors.white;
  }

  static Color divider(BuildContext context) {
    return isDark(context) ? const Color(0xFF3A3A3C) : const Color(0xFFD1D1D6);
  }

  static Color titleText(BuildContext context) {
    return isDark(context) ? const Color(0xFFF5F5F7) : const Color(0xFF1C1C1E);
  }

  static Color bodyText(BuildContext context) {
    return isDark(context) ? const Color(0xFFE5E5EA) : const Color(0xFF3A3A3C);
  }

  static Color secondaryText(BuildContext context) {
    return isDark(context) ? const Color(0xFFAEAEB2) : const Color(0xFF8E8E93);
  }

  static Color cardShadow(BuildContext context) {
    return isDark(context) ? const Color(0x33000000) : const Color(0x14000000);
  }
}

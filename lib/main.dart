import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/my_checks_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const MyInstallmentsApp());
}

class MyInstallmentsApp extends StatefulWidget {
  const MyInstallmentsApp({super.key});

  @override
  State<MyInstallmentsApp> createState() => _MyInstallmentsAppState();
}

class _MyInstallmentsAppState extends State<MyInstallmentsApp> {
  static const _darkModeKey = 'dark_mode_enabled';
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_darkModeKey) ?? false;
    if (!mounted) return;
    setState(() {
      _isDarkMode = saved;
    });
  }

  Future<void> _onThemeChanged(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = _isDarkMode ? Brightness.dark : Brightness.light;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        title: 'اقساط من',
        locale: const Locale('fa', 'IR'),
        supportedLocales: const [Locale('fa', 'IR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: CupertinoThemeData(
          brightness: brightness,
          scaffoldBackgroundColor: _isDarkMode
              ? const Color(0xFF0B0B0F)
              : const Color(0xFFF2F2F7),
          primaryColor: AppColors.primary,
          textTheme: const CupertinoTextThemeData(
            textStyle: TextStyle(fontFamily: 'Vazirmatn'),
            actionTextStyle: TextStyle(fontFamily: 'Vazirmatn'),
            tabLabelTextStyle: TextStyle(fontFamily: 'Vazirmatn'),
            navTitleTextStyle: TextStyle(fontFamily: 'Vazirmatn'),
            navLargeTitleTextStyle: TextStyle(fontFamily: 'Vazirmatn'),
            navActionTextStyle: TextStyle(fontFamily: 'Vazirmatn'),
            pickerTextStyle: TextStyle(fontFamily: 'Vazirmatn'),
            dateTimePickerTextStyle: TextStyle(fontFamily: 'Vazirmatn'),
          ),
        ),
        home: RootTabs(
          isDarkMode: _isDarkMode,
          onThemeChanged: _onThemeChanged,
        ),
      ),
    );
  }
}

class RootTabs extends StatefulWidget {
  const RootTabs({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<RootTabs> createState() => _RootTabsState();
}

class _RootTabsState extends State<RootTabs> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final accentColor = _currentIndex == 1
        ? AppColors.checksAccent
        : AppColors.primary;

    final screens = [
      const HomeScreen(),
      const MyChecksScreen(),
      const SearchScreen(),
      SettingsScreen(
        isDarkMode: widget.isDarkMode,
        onDarkModeChanged: widget.onThemeChanged,
      ),
    ];

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 110),
            child: IndexedStack(index: _currentIndex, children: screens),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 22,
            child: SafeArea(
              top: false,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(37),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        height: 74,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xCC000000),
                          borderRadius: BorderRadius.circular(37),
                          border: Border.all(
                            color: const Color(0x40FFFFFF),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cardShadow(context),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _TabItem(
                                icon: CupertinoIcons.settings,
                                label: 'تنظیمات',
                                accentColor: accentColor,
                                isActive: _currentIndex == 3,
                                onTap: () => setState(() => _currentIndex = 3),
                              ),
                            ),
                            Expanded(
                              child: _TabItem(
                                icon: CupertinoIcons.search,
                                label: 'جستجو',
                                accentColor: accentColor,
                                isActive: _currentIndex == 2,
                                onTap: () => setState(() => _currentIndex = 2),
                              ),
                            ),
                            const SizedBox(width: 78),
                            Expanded(
                              child: _TabItem(
                                icon: CupertinoIcons.doc_text_fill,
                                label: 'اقساط',
                                accentColor: accentColor,
                                isActive: _currentIndex == 0,
                                onTap: () => setState(() => _currentIndex = 0),
                              ),
                            ),
                            Expanded(
                              child: _TabItem(
                                icon: CupertinoIcons.doc_on_clipboard_fill,
                                label: 'چک ها',
                                accentColor: accentColor,
                                isActive: _currentIndex == 1,
                                onTap: () => setState(() => _currentIndex = 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -30,
                    child: GestureDetector(
                      onTap: () {
                        showCupertinoDialog<void>(
                          context: context,
                          builder: (_) => CupertinoAlertDialog(
                            title: const Text('افزودن قسط جدید'),
                            content: const Text(
                              'این بخش به زودی اضافه می شود.',
                            ),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text('باشه'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.add,
                          color: CupertinoColors.white,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accentColor;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = accentColor;
    final inactiveColor = CupertinoColors.white;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 74,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? activeColor : inactiveColor, size: 24),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'Vazirmatn',
                fontWeight: FontWeight.w600,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 3,
              width: isActive ? 24 : 0,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

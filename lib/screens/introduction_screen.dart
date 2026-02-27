import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key, required this.onCompleted});

  final Future<void> Function() onCompleted;

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  late final AnimationController _bgController;

  int _index = 0;
  bool _notifGranted = false;
  bool _calendarGranted = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat(reverse: true);
    _refreshPermissionStates();
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _refreshPermissionStates() async {
    final notif = await Permission.notification.status;
    final c1 = await Permission.calendarWriteOnly.status;
    final c2 = await Permission.calendarFullAccess.status;
    if (!mounted) return;
    setState(() {
      _notifGranted = notif.isGranted;
      _calendarGranted = c1.isGranted || c2.isGranted;
    });
  }

  Future<void> _requestNotifications() async {
    final result = await Permission.notification.request();
    if (!mounted) return;
    setState(() => _notifGranted = result.isGranted);
  }

  Future<void> _requestCalendar() async {
    var result = await Permission.calendarWriteOnly.request();
    if (!result.isGranted) {
      result = await Permission.calendarFullAccess.request();
    }
    if (!mounted) return;
    setState(() => _calendarGranted = result.isGranted);
  }

  Future<void> _nextOrDone() async {
    if (_index < 2) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    if (!_notifGranted || !_calendarGranted) {
      final shouldContinue = await showCupertinoDialog<bool>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text(
            '\u0646\u06cc\u0627\u0632 \u0628\u0647 \u0645\u062c\u0648\u0632\u0647\u0627',
            style: TextStyle(fontFamily: 'Vazirmatn'),
          ),
          content: const Text(
            '\u0627\u06af\u0631 \u062f\u0633\u062a\u0631\u0633\u06cc\u200c\u0647\u0627\u06cc \u0646\u0648\u062a\u06cc\u0641\u06cc\u06a9\u06cc\u0634\u0646 \u0648 \u062a\u0642\u0648\u06cc\u0645 \u0631\u0627 \u0646\u062f\u0647\u06cc\u062f\u060c \u06cc\u0627\u062f\u0622\u0648\u0631\u06cc \u0648 \u0627\u0639\u0644\u0627\u0646 \u0633\u0631\u0631\u0633\u06cc\u062f\u0647\u0627 \u0628\u0631\u0627\u06cc\u062a\u0627\u0646 \u0641\u0639\u0627\u0644 \u0646\u062e\u0648\u0627\u0647\u062f \u0634\u062f.',
            style: TextStyle(fontFamily: 'Vazirmatn'),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text(
                '\u0628\u0627\u0632\u06af\u0634\u062a',
                style: TextStyle(fontFamily: 'Vazirmatn'),
              ),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                '\u0627\u062f\u0627\u0645\u0647 \u0628\u062f\u0648\u0646 \u062f\u0633\u062a\u0631\u0633\u06cc',
                style: TextStyle(fontFamily: 'Vazirmatn'),
              ),
            ),
          ],
        ),
      );
      if (shouldContinue != true) return;
    }

    setState(() => _busy = true);
    await widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                final t = _bgController.value;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-0.9 + (t * 0.5), -1),
                      end: Alignment(1, 0.9 - (t * 0.4)),
                      colors: [
                        AppColors.primary.withValues(alpha: isDark ? 0.28 : 0.16),
                        AppColors.checksAccent.withValues(alpha: isDark ? 0.26 : 0.13),
                        isDark ? const Color(0xFF0B0B0F) : const Color(0xFFF2F2F7),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 110,
            right: -40,
            child: _GlowOrb(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          Positioned(
            bottom: 140,
            left: -30,
            child: _GlowOrb(color: AppColors.checksAccent.withValues(alpha: 0.16)),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      const Spacer(),
                      if (_index < 2)
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          onPressed: _nextOrDone,
                          child: Text(
                            '\u0631\u062f \u06a9\u0631\u062f\u0646',
                            style: TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 14,
                              color: AppColors.secondaryText(context),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (v) => setState(() => _index = v),
                    children: [
                      _FancySlide(
                        vectorAsset: 'assets/intro/installments.svg',
                        title: '\u0645\u062f\u06cc\u0631\u06cc\u062a \u0627\u0642\u0633\u0627\u0637 \u0628\u0627 \u06cc\u06a9 \u062f\u06cc\u062f \u06a9\u0627\u0645\u0644',
                        description:
                            '\u0648\u0627\u0645\u200c\u0647\u0627\u060c \u0645\u0628\u0627\u0644\u063a\u060c \u0633\u0631\u0631\u0633\u06cc\u062f\u0647\u0627 \u0648 \u067e\u06cc\u0634\u0631\u0641\u062a \u067e\u0631\u062f\u0627\u062e\u062a \u0631\u0627 \u062f\u0631 \u06cc\u06a9 \u062a\u0627\u06cc\u0645\u200c\u0644\u0627\u06cc\u0646 \u0634\u0641\u0627\u0641 \u0628\u0628\u06cc\u0646\u06cc\u062f.',
                      ),
                      _FancySlide(
                        vectorAsset: 'assets/intro/checks.svg',
                        title: '\u06a9\u0646\u062a\u0631\u0644 \u062d\u0631\u0641\u0647\u200c\u0627\u06cc \u0686\u06a9\u200c\u0647\u0627',
                        description:
                            '\u0686\u06a9\u200c\u0647\u0627\u06cc \u062f\u0631\u06cc\u0627\u0641\u062a\u06cc \u0648 \u067e\u0631\u062f\u0627\u062e\u062a\u06cc \u0631\u0627 \u0628\u0627 \u0648\u0636\u0639\u06cc\u062a \u062f\u0642\u06cc\u0642 \u0648 \u0633\u0631\u0631\u0633\u06cc\u062f\u0647\u0627\u06cc \u0646\u0632\u062f\u06cc\u06a9 \u0645\u062f\u06cc\u0631\u06cc\u062a \u06a9\u0646\u06cc\u062f.',
                      ),
                      _PermissionFancySlide(
                        vectorAsset: 'assets/intro/permissions.svg',
                        notifGranted: _notifGranted,
                        calendarGranted: _calendarGranted,
                        onNotifTap: _requestNotifications,
                        onCalendarTap: _requestCalendar,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (i) {
                          final active = i == _index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primary
                                  : AppColors.secondaryText(context)
                                      .withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton.filled(
                          borderRadius: BorderRadius.circular(16),
                          onPressed: _busy ? null : _nextOrDone,
                          child: _busy
                              ? const CupertinoActivityIndicator()
                              : Text(
                                  _index < 2
                                      ? '\u0627\u062f\u0627\u0645\u0647'
                                      : '\u0634\u0631\u0648\u0639 \u06a9\u0627\u0631 \u0628\u0627 \u0628\u0631\u0646\u0627\u0645\u0647',
                                  style: const TextStyle(
                                    fontFamily: 'Vazirmatn',
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FancySlide extends StatelessWidget {
  const _FancySlide({
    required this.vectorAsset,
    required this.title,
    required this.description,
  });

  final String vectorAsset;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.sectionBackground(context).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.divider(context), width: 0.7),
            ),
            child: SvgPicture.asset(
              vectorAsset,
              height: 150,
              colorFilter: ColorFilter.mode(
                AppColors.titleText(context),
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: AppColors.titleText(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 14.5,
              height: 1.85,
              color: AppColors.bodyText(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionFancySlide extends StatelessWidget {
  const _PermissionFancySlide({
    required this.vectorAsset,
    required this.notifGranted,
    required this.calendarGranted,
    required this.onNotifTap,
    required this.onCalendarTap,
  });

  final String vectorAsset;
  final bool notifGranted;
  final bool calendarGranted;
  final VoidCallback onNotifTap;
  final VoidCallback onCalendarTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 220,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.sectionBackground(context).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.divider(context), width: 0.7),
            ),
            child: SvgPicture.asset(
              vectorAsset,
              height: 120,
              colorFilter: ColorFilter.mode(
                AppColors.titleText(context),
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '\u0645\u062c\u0648\u0632\u0647\u0627\u06cc \u0644\u0627\u0632\u0645 \u06cc\u0627\u062f\u0622\u0648\u0631\u06cc',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.titleText(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\u0628\u0631\u0627\u06cc \u062f\u0631\u06cc\u0627\u0641\u062a \u0627\u0639\u0644\u0627\u0646\u200c\u0647\u0627\u06cc \u062f\u0642\u06cc\u0642\u060c \u0644\u0637\u0641\u0627\u064b \u0645\u062c\u0648\u0632\u0647\u0627 \u0631\u0627 \u0641\u0639\u0627\u0644 \u06a9\u0646\u06cc\u062f.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 14,
              height: 1.7,
              color: AppColors.bodyText(context),
            ),
          ),
          const SizedBox(height: 18),
          _PermissionTile(
            icon: CupertinoIcons.bell_fill,
            title: '\u062f\u0633\u062a\u0631\u0633\u06cc \u0646\u0648\u062a\u06cc\u0641\u06cc\u06a9\u06cc\u0634\u0646',
            granted: notifGranted,
            onTap: onNotifTap,
          ),
          const SizedBox(height: 10),
          _PermissionTile(
            icon: CupertinoIcons.calendar,
            title: '\u062f\u0633\u062a\u0631\u0633\u06cc \u062a\u0642\u0648\u06cc\u0645',
            granted: calendarGranted,
            onTap: onCalendarTap,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.granted,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool granted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.sectionBackground(context).withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider(context), width: 0.7),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        onPressed: onTap,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.titleText(context),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: granted
                    ? CupertinoColors.activeGreen.withValues(alpha: 0.18)
                    : CupertinoColors.systemGrey.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                granted ? '\u0641\u0639\u0627\u0644' : '\u063a\u06cc\u0631\u0641\u0639\u0627\u0644',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: granted
                      ? CupertinoColors.activeGreen
                      : AppColors.secondaryText(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.01)],
          ),
        ),
      ),
    );
  }
}

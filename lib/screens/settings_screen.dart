import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/ios_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
    required this.onExportBackup,
    required this.onImportBackup,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  final Future<String> Function() onExportBackup;
  final Future<String> Function() onImportBackup;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  late bool darkModeEnabled;

  @override
  void initState() {
    super.initState();
    darkModeEnabled = widget.isDarkMode;
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      darkModeEnabled = widget.isDarkMode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          '\u062a\u0646\u0638\u06cc\u0645\u0627\u062a',
          style: TextStyle(
            color: AppColors.titleText(context),
            fontFamily: 'Vazirmatn',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                '\u062a\u0646\u0638\u06cc\u0645\u0627\u062a',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.titleText(context),
                  fontFamily: 'Vazirmatn',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            IosSection(
              title: '\u0639\u0645\u0648\u0645\u06cc',
              children: [
                _switchRow(
                  title: '\u0627\u0639\u0644\u0627\u0646\u200c\u0647\u0627',
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      notificationsEnabled = value;
                    });
                  },
                ),
                _switchRow(
                  title: '\u062d\u0627\u0644\u062a \u062a\u0627\u0631\u06cc\u06a9',
                  value: darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      darkModeEnabled = value;
                    });
                    widget.onDarkModeChanged(value);
                  },
                ),
                _navigationRow(
                  title: '\u067e\u0634\u062a\u06cc\u0628\u0627\u0646\u200c\u06af\u06cc\u0631\u06cc \u0627\u0632 \u0627\u0637\u0644\u0627\u0639\u0627\u062a',
                  onTap: () => _showBackupSheet(context),
                ),
                _navigationRow(
                  title: '\u062f\u0631\u0628\u0627\u0631\u0647 \u0628\u0631\u0646\u0627\u0645\u0647',
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute<void>(
                        builder: (_) => const _AboutScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 16,
                color: AppColors.bodyText(context),
              ),
            ),
          ),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _navigationRow({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 16,
                  color: AppColors.bodyText(context),
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_back,
              size: 18,
              color: AppColors.secondaryText(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: const Text(
          '\u067e\u0634\u062a\u06cc\u0628\u0627\u0646\u200c\u06af\u06cc\u0631\u06cc',
          style: TextStyle(fontFamily: 'Vazirmatn'),
        ),
        message: const Text(
          '\u06cc\u06a9\u06cc \u0627\u0632 \u06af\u0632\u06cc\u0646\u0647\u200c\u0647\u0627 \u0631\u0627 \u0627\u0646\u062a\u062e\u0627\u0628 \u06a9\u0646\u06cc\u062f.',
          style: TextStyle(fontFamily: 'Vazirmatn'),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(sheetContext).pop();
              await _handleExport();
            },
            child: const Text(
              '\u062e\u0631\u0648\u062c \u0627\u0637\u0644\u0627\u0639\u0627\u062a',
              style: TextStyle(fontFamily: 'Vazirmatn'),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(sheetContext).pop();
              await _handleImport();
            },
            child: const Text(
              '\u0648\u0631\u0648\u062f \u0627\u0637\u0644\u0627\u0639\u0627\u062a',
              style: TextStyle(fontFamily: 'Vazirmatn'),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: const Text(
            '\u0627\u0646\u0635\u0631\u0627\u0641',
            style: TextStyle(fontFamily: 'Vazirmatn'),
          ),
        ),
      ),
    );
  }

  Future<void> _handleExport() async {
    try {
      final path = await widget.onExportBackup();
      if (!mounted) return;
      final inDownloads = path.contains('/Download/') || path.contains('\\Download\\');
      final msg = inDownloads
          ? '\u0641\u0627\u06cc\u0644 \u067e\u0634\u062a\u06cc\u0628\u0627\u0646 \u062f\u0631 \u067e\u0648\u0634\u0647 Downloads \u0630\u062e\u06cc\u0631\u0647 \u0634\u062f:\n$path'
          : '\u0641\u0627\u06cc\u0644 \u067e\u0634\u062a\u06cc\u0628\u0627\u0646 \u0633\u0627\u062e\u062a\u0647 \u0634\u062f:\n$path';
      await _showInfoDialog(
        context,
        title: '\u062e\u0631\u0648\u062c \u0645\u0648\u0641\u0642',
        message: msg,
      );
    } catch (_) {
      if (!mounted) return;
      await _showInfoDialog(
        context,
        title: '\u062e\u0637\u0627',
        message:
            '\u062f\u0631 \u0633\u0627\u062e\u062a \u0641\u0627\u06cc\u0644 \u067e\u0634\u062a\u06cc\u0628\u0627\u0646 \u0645\u0634\u06a9\u0644\u06cc \u0627\u06cc\u062c\u0627\u062f \u0634\u062f.',
      );
    }
  }

  Future<void> _handleImport() async {
    try {
      final importedPath = await widget.onImportBackup();
      if (!mounted) return;
      if (importedPath.isEmpty) {
        await _showInfoDialog(
          context,
          title: '\u0644\u063a\u0648 \u0634\u062f',
          message: '\u0641\u0627\u06cc\u0644\u06cc \u0627\u0646\u062a\u062e\u0627\u0628 \u0646\u0634\u062f.',
        );
        return;
      }
      await _showInfoDialog(
        context,
        title: '\u0648\u0631\u0648\u062f \u0645\u0648\u0641\u0642',
        message:
            '\u0627\u0637\u0644\u0627\u0639\u0627\u062a \u0628\u0627 \u0645\u0648\u0641\u0642\u06cc\u062a \u0627\u0632 \u0641\u0627\u06cc\u0644 \u0632\u06cc\u0631 \u0648\u0627\u0631\u062f \u0634\u062f:\n$importedPath',
      );
    } catch (e) {
      if (!mounted) return;
      final reason = e.toString();
      await _showInfoDialog(
        context,
        title: '\u062e\u0637\u0627',
        message:
            '\u0641\u0627\u06cc\u0644 \u0648\u0631\u0648\u062f\u06cc \u0642\u0627\u0628\u0644 \u067e\u0631\u062f\u0627\u0632\u0634 \u0646\u06cc\u0633\u062a.\n$reason',
      );
    }
  }

  Future<void> _showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (dctx) => CupertinoAlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontFamily: 'Vazirmatn'),
        ),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Vazirmatn'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dctx).pop(),
            child: const Text(
              '\u0628\u0633\u062a\u0646',
              style: TextStyle(fontFamily: 'Vazirmatn'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutScreen extends StatelessWidget {
  const _AboutScreen();

  static final Uri _websiteUri = Uri.parse('https://bizto.ir/');
  static final Uri _phoneUri = Uri.parse('tel:+989137640338');
  static final Uri _whatsappUri = Uri.parse('https://wa.me/989137640338');
  static final Uri _telegramUri = Uri.parse('https://t.me/aminkhaleghi');
  static final Uri _telegramAppUri = Uri.parse('tg://resolve?domain=aminkhaleghi');
  static final Uri _emailUri = Uri.parse(
    'mailto:akhalleghi@gmail.com?subject=%D8%AF%D8%B1%D8%AE%D9%88%D8%A7%D8%B3%D8%AA%20%D8%B7%D8%B1%D8%A7%D8%AD%DB%8C%20%D9%BE%D8%B1%D9%88%DA%98%D9%87',
  );

  Future<void> _openUri(
    BuildContext context,
    Uri uri, {
    Uri? fallbackUri,
  }) async {
    var ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && fallbackUri != null) {
      ok = await launchUrl(
        fallbackUri,
        mode: LaunchMode.externalApplication,
      );
    }
    if (!ok && context.mounted) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text(
            '\u062e\u0637\u0627',
            style: TextStyle(fontFamily: 'Vazirmatn'),
          ),
          content: const Text(
            '\u0627\u0645\u06a9\u0627\u0646 \u0628\u0627\u0632 \u06a9\u0631\u062f\u0646 \u0627\u06cc\u0646 \u0644\u06cc\u0646\u06a9 \u0648\u062c\u0648\u062f \u0646\u062f\u0627\u0631\u062f.',
            style: TextStyle(fontFamily: 'Vazirmatn'),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                '\u0628\u0633\u062a\u0646',
                style: TextStyle(fontFamily: 'Vazirmatn'),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: const CupertinoNavigationBarBackButton(
          color: AppColors.primary,
        ),
        previousPageTitle: '\u062a\u0646\u0638\u06cc\u0645\u0627\u062a',
        middle: Text(
          '\u062f\u0631\u0628\u0627\u0631\u0647 \u0645\u0627',
          style: TextStyle(
            color: AppColors.titleText(context),
            fontFamily: 'Vazirmatn',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF0A84FF), Color(0xFF0063CC)],
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
                  Container(
                    width: 88,
                    height: 88,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset(
                      'assets/img/logo.webp',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\u062a\u06cc\u0645 \u062a\u0648\u0633\u0639\u0647 \u0646\u0631\u0645 \u0627\u0641\u0632\u0627\u0631 \u0628\u06cc\u0632\u062a\u0648',
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: CupertinoColors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '\u0637\u0631\u0627\u062d\u06cc \u0648\u0628 \u0648 \u0627\u0646\u062f\u0631\u0648\u06cc\u062f',
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 13,
                            color: Color(0xE6FFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.sectionBackground(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider(context), width: 0.7),
              ),
              child: Text(
                '\u0628\u06cc\u0632\u062a\u0648 \u06cc\u06a9 \u062a\u06cc\u0645 \u062e\u0644\u0627\u0642 \u0628\u0631\u0627\u06cc \u0637\u0631\u0627\u062d\u06cc \u0648 \u062a\u0648\u0633\u0639\u0647 \u0648\u0628\u200c\u0633\u0627\u06cc\u062a \u0648 \u0627\u067e\u0644\u06cc\u06a9\u06cc\u0634\u0646 \u0627\u0646\u062f\u0631\u0648\u06cc\u062f \u0627\u0633\u062a. \u0627\u06af\u0631 \u0628\u0631\u0627\u06cc \u067e\u0631\u0648\u0698\u0647 \u062c\u062f\u06cc\u062f \u06cc\u0627 \u0628\u0647\u0628\u0648\u062f \u0645\u062d\u0635\u0648\u0644 \u0641\u0639\u0644\u06cc \u062e\u0648\u062f \u0628\u0647 \u0645\u0634\u0627\u0648\u0631\u0647 \u0646\u06cc\u0627\u0632 \u062f\u0627\u0631\u06cc\u062f\u060c \u067e\u06cc\u0627\u0645 \u0628\u062f\u0647\u06cc\u062f.',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 14,
                  height: 1.8,
                  color: AppColors.bodyText(context),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '\u0631\u0627\u0647\u200c\u0647\u0627\u06cc \u0627\u0631\u062a\u0628\u0627\u0637 \u0628\u0627 \u0645\u0627',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.titleText(context),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ContactTile(
              icon: CupertinoIcons.globe,
              title: '\u0648\u0628\u200c\u0633\u0627\u06cc\u062a',
              value: 'https://bizto.ir/',
              onTap: () => _openUri(context, _websiteUri),
            ),
            _ContactTile(
              icon: CupertinoIcons.phone_fill,
              title: '\u062a\u0645\u0627\u0633',
              value: '+98 913 764 0338',
              forceLtrValue: true,
              onTap: () => _openUri(context, _phoneUri),
            ),
            _ContactTile(
              icon: CupertinoIcons.chat_bubble_2_fill,
              title: '\u0648\u0627\u062a\u0633\u200c\u0627\u067e',
              value: 'wa.me/989137640338',
              forceLtrValue: true,
              onTap: () => _openUri(context, _whatsappUri),
            ),
            _ContactTile(
              icon: CupertinoIcons.paperplane_fill,
              title: '\u062a\u0644\u06af\u0631\u0627\u0645',
              value: '@aminkhaleghi',
              forceLtrValue: true,
              onTap: () => _openUri(
                context,
                _telegramAppUri,
                fallbackUri: _telegramUri,
              ),
            ),
            _ContactTile(
              icon: CupertinoIcons.mail_solid,
              title: '\u0627\u06cc\u0645\u06cc\u0644',
              value: 'akhalleghi@gmail.com',
              forceLtrValue: true,
              onTap: () => _openUri(context, _emailUri),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '\u0628\u0631\u0627\u06cc \u0633\u0641\u0627\u0631\u0634 \u0637\u0631\u0627\u062d\u06cc \u0633\u0627\u06cc\u062a \u06cc\u0627 \u0627\u067e \u0627\u0646\u062f\u0631\u0648\u06cc\u062f\u060c \u0627\u0632 \u0647\u0631 \u06a9\u062f\u0627\u0645 \u0627\u0632 \u0631\u0627\u0647\u200c\u0647\u0627\u06cc \u0628\u0627\u0644\u0627 \u0645\u0633\u062a\u0642\u06cc\u0645 \u067e\u06cc\u0627\u0645 \u0628\u062f\u0647\u06cc\u062f.',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.titleText(context),
                  height: 1.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.forceLtrValue = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final bool forceLtrValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.sectionBackground(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider(context), width: 0.7),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 12,
                      color: AppColors.secondaryText(context),
                    ),
                  ),
                  Text(
                    value,
                    textDirection: forceLtrValue
                        ? TextDirection.ltr
                        : TextDirection.rtl,
                    textAlign: forceLtrValue ? TextAlign.left : TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.titleText(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_back,
              color: AppColors.secondaryText(context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

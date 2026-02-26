import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../models/finance_items.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class CheckDetailsResult {
  const CheckDetailsResult({this.deleted = false, this.updatedItem});
  final bool deleted;
  final CheckItem? updatedItem;
}

class CheckDetailsScreen extends StatefulWidget {
  const CheckDetailsScreen({super.key, required this.item});

  final CheckItem item;

  @override
  State<CheckDetailsScreen> createState() => _CheckDetailsScreenState();
}

class _CheckDetailsScreenState extends State<CheckDetailsScreen>
    with SingleTickerProviderStateMixin {
  late CheckItem _item;
  late final AnimationController _celebrationController;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amount = int.tryParse(_item.amount) ?? 0;
    final isReceived = _item.checkType == 'received';
    final typeLabel = isReceived
        ? '\u062f\u0631\u06cc\u0627\u0641\u062a\u06cc'
        : '\u067e\u0631\u062f\u0627\u062e\u062a\u06cc';
    final typeColor = isReceived
        ? AppColors.checksAccent
        : CupertinoColors.systemOrange;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _popWithUpdate();
      },
      child: Stack(
        children: [
          CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _popWithUpdate,
                child: const Icon(
                  CupertinoIcons.chevron_forward,
                  color: AppColors.primary,
                ),
              ),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _confirmDelete(context),
                child: const Icon(
                  CupertinoIcons.delete_solid,
                  color: CupertinoColors.systemRed,
                  size: 22,
                ),
              ),
              middle: Text(
                '\u062c\u0632\u0626\u06cc\u0627\u062a \u0686\u06a9',
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
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0xFF30B28C), Color(0xFF0E8D68)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cardShadow(context),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Vazirmatn',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              color: _item.isSettled
                                  ? CupertinoColors.activeGreen.withValues(alpha: 0.28)
                                  : CupertinoColors.systemBlue.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(12),
                              onPressed: _item.isSettled
                                  ? null
                                  : () => _confirmSettle(isReceived),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _item.isSettled
                                        ? CupertinoIcons.checkmark_seal_fill
                                        : (isReceived
                                              ? CupertinoIcons.arrow_down_circle_fill
                                              : CupertinoIcons.arrow_up_circle_fill),
                                    size: 16,
                                    color: CupertinoColors.white,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    _item.isSettled
                                        ? (isReceived
                                              ? '\u062f\u0631\u06cc\u0627\u0641\u062a \u0634\u062f\u0647'
                                              : '\u067e\u0631\u062f\u0627\u062e\u062a \u0634\u062f\u0647')
                                        : (isReceived
                                              ? '\u062b\u0628\u062a \u062f\u0631\u06cc\u0627\u0641\u062a \u0627\u06cc\u0646 \u0686\u06a9'
                                              : '\u062b\u0628\u062a \u067e\u0631\u062f\u0627\u062e\u062a \u0627\u06cc\u0646 \u0686\u06a9'),
                                    style: const TextStyle(
                                      fontFamily: 'Vazirmatn',
                                      color: CupertinoColors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${NumberFormat('#,###').format(amount)} \u062a\u0648\u0645\u0627\u0646',
                          style: const TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: CupertinoColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: CupertinoColors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                typeLabel,
                                style: const TextStyle(
                                  fontFamily: 'Vazirmatn',
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (_item.isSettled) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.activeGreen.withValues(alpha: 0.24),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  isReceived
                                      ? '\u062f\u0631\u06cc\u0627\u0641\u062a \u0634\u062f\u0647'
                                      : '\u067e\u0631\u062f\u0627\u062e\u062a \u0634\u062f\u0647',
                                  style: const TextStyle(
                                    fontFamily: 'Vazirmatn',
                                    color: CupertinoColors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _section(
                    context,
                    title: '\u0627\u0637\u0644\u0627\u0639\u0627\u062a \u0686\u06a9',
                    children: [
                      _row(context, '\u0637\u0631\u0641 \u062d\u0633\u0627\u0628', _item.counterparty, CupertinoIcons.person_crop_circle),
                      _row(context, '\u0646\u0648\u0639 \u0686\u06a9', typeLabel, CupertinoIcons.doc_text_fill, valueColor: typeColor),
                      _row(context, '\u062a\u0627\u0631\u06cc\u062e \u0633\u0631\u0631\u0633\u06cc\u062f', _item.dueDate, CupertinoIcons.calendar),
                      _row(context, '\u062a\u0627\u0631\u06cc\u062e \u0635\u062f\u0648\u0631', _emptyDash(_item.issueDate), CupertinoIcons.clock),
                      _row(context, '\u0634\u0645\u0627\u0631\u0647 \u0686\u06a9', _emptyDash(_item.checkNumber), CupertinoIcons.number),
                      _row(context, '\u0634\u0645\u0627\u0631\u0647 \u0635\u06cc\u0627\u062f\u06cc', _emptyDash(_item.sayadiNumber), CupertinoIcons.barcode),
                      _row(context, '\u0646\u0627\u0645 \u0628\u0627\u0646\u06a9', _emptyDash(_item.bankName), CupertinoIcons.building_2_fill),
                      _row(context, '\u062a\u0648\u0636\u06cc\u062d\u0627\u062a', _emptyDash(_item.note), CupertinoIcons.text_alignright),
                    ],
                  ),
                  if (_item.imagePath.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _section(
                      context,
                      title: '\u062a\u0635\u0648\u06cc\u0631 \u0686\u06a9',
                      children: [
                        GestureDetector(
                          onTap: () => _showImagePreview(context, _item.imagePath),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_item.imagePath),
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => SizedBox(
                                height: 80,
                                child: Center(
                                  child: Text(
                                    '\u062a\u0635\u0648\u06cc\u0631 \u0642\u0627\u0628\u0644 \u0646\u0645\u0627\u06cc\u0634 \u0646\u06cc\u0633\u062a',
                                    style: TextStyle(
                                      fontFamily: 'Vazirmatn',
                                      color: AppColors.secondaryText(context),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_showCelebration) _celebrationOverlay(isReceived),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sectionBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider(context), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontWeight: FontWeight.w700,
              color: AppColors.titleText(context),
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String title,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 12,
                color: AppColors.secondaryText(context),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 13.2,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.titleText(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _emptyDash(String value) {
    return value.trim().isEmpty ? '-' : value;
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          '\u062d\u0630\u0641 \u0686\u06a9',
          style: TextStyle(fontFamily: 'Vazirmatn'),
        ),
        content: const Text(
          '\u0622\u06cc\u0627 \u0645\u0637\u0645\u0626\u0646 \u0647\u0633\u062a\u06cc\u062f \u06a9\u0647 \u0627\u06cc\u0646 \u0686\u06a9 \u062d\u0630\u0641 \u0634\u0648\u062f\u061f',
          style: TextStyle(fontFamily: 'Vazirmatn'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              '\u0627\u0646\u0635\u0631\u0627\u0641',
              style: TextStyle(fontFamily: 'Vazirmatn'),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              '\u062d\u0630\u0641',
              style: TextStyle(fontFamily: 'Vazirmatn'),
            ),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      Navigator.of(this.context).pop(const CheckDetailsResult(deleted: true));
    }
  }

  Future<void> _confirmSettle(bool isReceived) async {
    final action = isReceived
        ? '\u062f\u0631\u06cc\u0627\u0641\u062a'
        : '\u067e\u0631\u062f\u0627\u062e\u062a';
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          '\u062a\u0627\u06cc\u06cc\u062f \u0639\u0645\u0644\u06cc\u0627\u062a',
          style: TextStyle(fontFamily: 'Vazirmatn'),
        ),
        content: Text(
          '\u0622\u06cc\u0627 \u0627\u0632 $action \u0627\u06cc\u0646 \u0686\u06a9 \u0645\u0637\u0645\u0626\u0646 \u0647\u0633\u062a\u06cc\u062f\u061f',
          style: const TextStyle(fontFamily: 'Vazirmatn'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              '\u0627\u0646\u0635\u0631\u0627\u0641',
              style: TextStyle(fontFamily: 'Vazirmatn'),
            ),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              '\u0628\u0644\u0647',
              style: TextStyle(fontFamily: 'Vazirmatn'),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() {
      _item = _item.copyWith(isSettled: true);
      _showCelebration = true;
    });
    await _celebrationController.forward(from: 0);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _showCelebration = false);
  }

  Widget _celebrationOverlay(bool isReceived) {
    final text = isReceived
        ? '\u062f\u0631\u06cc\u0627\u0641\u062a \u0628\u0627 \u0645\u0648\u0641\u0642\u06cc\u062a \u062b\u0628\u062a \u0634\u062f'
        : '\u067e\u0631\u062f\u0627\u062e\u062a \u0628\u0627 \u0645\u0648\u0641\u0642\u06cc\u062a \u062b\u0628\u062a \u0634\u062f';
    return IgnorePointer(
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _celebrationController,
            curve: const Interval(0, 0.35, curve: Curves.easeOut),
          ),
        ),
        child: Container(
          color: CupertinoColors.black.withValues(alpha: 0.08),
          child: Center(
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.75, end: 1.0).animate(
                CurvedAnimation(
                  parent: _celebrationController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: Container(
                width: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.sectionBackground(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.checkmark_seal_fill,
                      color: CupertinoColors.activeGreen,
                      size: 46,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.titleText(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePreview(BuildContext context, String path) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        color: CupertinoColors.black.withValues(alpha: 0.92),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Image.file(File(path)),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: CupertinoButton(
                  padding: const EdgeInsets.all(8),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(
                    CupertinoIcons.clear_circled_solid,
                    color: CupertinoColors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _popWithUpdate() {
    Navigator.of(context).pop(CheckDetailsResult(updatedItem: _item));
  }
}

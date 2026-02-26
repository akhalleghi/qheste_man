import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../models/finance_items.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class InstallmentDetailsResult {
  const InstallmentDetailsResult({this.updatedItem, this.deleted = false});

  final InstallmentItem? updatedItem;
  final bool deleted;
}

class InstallmentDetailsScreen extends StatefulWidget {
  const InstallmentDetailsScreen({super.key, required this.installment});

  final InstallmentItem installment;

  @override
  State<InstallmentDetailsScreen> createState() => _InstallmentDetailsScreenState();
}

class _InstallmentDetailsScreenState extends State<InstallmentDetailsScreen>
    with SingleTickerProviderStateMixin {
  late InstallmentItem _workingInstallment;
  final NumberFormat _currencyFormatter = NumberFormat('#,###');
  final ImagePicker _imagePicker = ImagePicker();
  late final AnimationController _celebrationController;
  bool _showCelebration = false;
  static const TextStyle _vazirDialogStyle = TextStyle(fontFamily: 'Vazirmatn');

  @override
  void initState() {
    super.initState();
    _workingInstallment = widget.installment;
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
    final schedule = _buildSchedule(_workingInstallment);
    final paidCount = _workingInstallment.paidInstallmentIndexes.length;
    final totalCount = _workingInstallment.durationMonths;
    final progress = totalCount == 0 ? 0.0 : (paidCount / totalCount).clamp(0.0, 1.0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _popWithResult();
      },
      child: Stack(
        children: [
          CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _popWithResult,
                child: const Icon(
                  CupertinoIcons.chevron_forward,
                  color: AppColors.primary,
                ),
              ),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _onDeletePressed,
                child: const Icon(
                  CupertinoIcons.delete_solid,
                  color: CupertinoColors.systemRed,
                  size: 22,
                ),
              ),
              previousPageTitle: '\u062e\u0627\u0646\u0647',
              middle: Text(
                _workingInstallment.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.titleText(context),
                  fontFamily: 'Vazirmatn',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  140,
                ),
                children: [
                  _heroSummary(progress, paidCount, totalCount),
                  const SizedBox(height: AppSpacing.md),
                  _overviewGrid(),
                  const SizedBox(height: AppSpacing.md),
                  _sectionTitle('\u0644\u06cc\u0633\u062a \u0627\u0642\u0633\u0627\u0637'),
                  const SizedBox(height: 8),
                  ...List.generate(
                    schedule.length,
                    (index) => _scheduleCard(schedule[index], index),
                  ),
                ],
              ),
            ),
          ),
          if (_showCelebration) _celebrationOverlay(),
        ],
      ),
    );
  }

  Widget _heroSummary(double progress, int paidCount, int totalCount) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF0A84FF), Color(0xFF0063CC)],
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
          Text(
            _workingInstallment.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 7,
            decoration: BoxDecoration(
              color: const Color(0x36FFFFFF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '$paidCount \u0627\u0632 $totalCount \u0642\u0633\u0637 \u067e\u0631\u062f\u0627\u062e\u062a \u0634\u062f\u0647',
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewGrid() {
    final totalAmount = _toNumber(_workingInstallment.totalAmount);
    final remainingAmount = _toNumber(_workingInstallment.remainingAmount);
    final paidSoFar = (totalAmount - remainingAmount).clamp(0, totalAmount);
    final noteValue = _workingInstallment.note.trim().isEmpty
        ? '\u0628\u062f\u0648\u0646 \u062a\u0648\u0636\u06cc\u062d'
        : _workingInstallment.note.trim();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sectionBackground(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider(context), width: 0.8),
      ),
      child: Column(
        children: [
          _overviewItem(
            title: '\u0645\u0648\u0633\u0633\u0647',
            value: _workingInstallment.lenderName,
            icon: CupertinoIcons.building_2_fill,
          ),
          _overviewItem(
            title: '\u0645\u0628\u0644\u063a \u06a9\u0644',
            value: '${_currencyFormatter.format(totalAmount)} \u062a\u0648\u0645\u0627\u0646',
            icon: CupertinoIcons.money_dollar_circle_fill,
          ),
          _overviewItem(
            title: '\u0628\u0627\u0642\u06cc\u0645\u0627\u0646\u062f\u0647',
            value:
                '${_currencyFormatter.format(remainingAmount)} \u062a\u0648\u0645\u0627\u0646',
            icon: CupertinoIcons.chart_pie_fill,
          ),
          _overviewItem(
            title: '\u067e\u0631\u062f\u0627\u062e\u062a\u200c\u0634\u062f\u0647 \u062a\u0627\u06a9\u0646\u0648\u0646',
            value: '${_currencyFormatter.format(paidSoFar)} \u062a\u0648\u0645\u0627\u0646',
            icon: CupertinoIcons.checkmark_shield_fill,
          ),
          _overviewItem(
            title: '\u0645\u0628\u0644\u063a \u0647\u0631 \u0642\u0633\u0637',
            value:
                '${_currencyFormatter.format(_toNumber(_workingInstallment.monthlyInstallmentAmount))} \u062a\u0648\u0645\u0627\u0646',
            icon: CupertinoIcons.creditcard_fill,
          ),
          _overviewItem(
            title: '\u062a\u0627\u0631\u06cc\u062e \u0634\u0631\u0648\u0639',
            value: _workingInstallment.firstDueDate,
            icon: CupertinoIcons.calendar,
          ),
          _overviewItem(
            title: '\u067e\u0631\u062f\u0627\u062e\u062a \u0628\u0639\u062f\u06cc',
            value: _workingInstallment.nextPaymentDate,
            icon: CupertinoIcons.alarm_fill,
          ),
          _overviewItem(
            title: '\u062a\u0648\u0636\u06cc\u062d\u0627\u062a',
            value: noteValue,
            icon: CupertinoIcons.text_alignright,
          ),
        ],
      ),
    );
  }

  Widget _overviewItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider(context), width: 0.75),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const SizedBox(width: 6),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 12,
                          color: AppColors.secondaryText(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        value,
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 13.2,
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                          color: AppColors.titleText(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.titleText(context),
      ),
    );
  }

  Widget _scheduleCard(_InstallmentScheduleEntry entry, int index) {
    final isPaid = _workingInstallment.paidInstallmentIndexes.contains(index);
    final receiptPath = _workingInstallment.installmentReceiptPaths['$index'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sectionBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider(context), width: 0.8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isPaid
                      ? CupertinoColors.activeGreen.withValues(alpha: 0.14)
                      : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isPaid ? CupertinoIcons.check_mark : CupertinoIcons.clock,
                  size: 18,
                  color: isPaid ? CupertinoColors.activeGreen : AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '\u0642\u0633\u0637 ${index + 1} - ${entry.dueDate}',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontWeight: FontWeight.w700,
                    color: AppColors.titleText(context),
                  ),
                ),
              ),
              Text(
                '${_currencyFormatter.format(entry.amount)} \u062a\u0648\u0645\u0627\u0646',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontWeight: FontWeight.w700,
                  color: AppColors.titleText(context),
                ),
              ),
            ],
          ),
          if (receiptPath != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showReceiptPreview(receiptPath),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Image.file(
                    File(receiptPath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.background(context),
                      alignment: Alignment.center,
                      child: Text(
                        '\u0631\u0633\u06cc\u062f \u0642\u0627\u0628\u0644 \u0646\u0645\u0627\u06cc\u0634 \u0646\u06cc\u0633\u062a',
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
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    borderRadius: BorderRadius.circular(12),
                    color: isPaid
                        ? CupertinoColors.activeGreen.withValues(alpha: 0.15)
                        : AppColors.primary.withValues(alpha: 0.12),
                    onPressed: isPaid ? null : () => _onPayPressed(index),
                    child: Text(
                      isPaid
                          ? '\u067e\u0631\u062f\u0627\u062e\u062a \u0634\u062f\u0647'
                          : '\u067e\u0631\u062f\u0627\u062e\u062a \u0634\u062f',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        color: isPaid ? CupertinoColors.activeGreen : AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (isPaid) ...[
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    borderRadius: BorderRadius.circular(12),
                    color: CupertinoColors.systemRed.withValues(alpha: 0.12),
                    onPressed: () => _confirmUndoPayment(index),
                    child: const Text(
                      '\u0644\u063a\u0648 \u067e\u0631\u062f\u0627\u062e\u062a',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        color: CupertinoColors.systemRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onPayPressed(int installmentIndex) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text(
          '\u062b\u0628\u062a \u067e\u0631\u062f\u0627\u062e\u062a',
          style: _vazirDialogStyle,
        ),
        message: const Text(
          '\u0622\u06cc\u0627 \u0645\u06cc\u200c\u062e\u0648\u0627\u0647\u06cc\u062f \u0631\u0633\u06cc\u062f \u067e\u0631\u062f\u0627\u062e\u062a \u0647\u0645 \u0627\u0641\u0632\u0648\u062f\u0647 \u0634\u0648\u062f\u061f',
          style: _vazirDialogStyle,
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(context).pop();
              await _pickReceiptAndApplyPayment(
                installmentIndex,
                source: _ReceiptSource.gallery,
              );
            },
            child: const Text(
              '\u067e\u0631\u062f\u0627\u062e\u062a \u0628\u0627 \u0631\u0633\u06cc\u062f \u0627\u0632 \u06af\u0627\u0644\u0631\u06cc',
              style: _vazirDialogStyle,
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(context).pop();
              await _pickReceiptAndApplyPayment(
                installmentIndex,
                source: _ReceiptSource.camera,
              );
            },
            child: const Text(
              '\u067e\u0631\u062f\u0627\u062e\u062a \u0628\u0627 \u0639\u06a9\u0633 \u062f\u0648\u0631\u0628\u06cc\u0646',
              style: _vazirDialogStyle,
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(context).pop();
              await _pickReceiptAndApplyPayment(
                installmentIndex,
                source: _ReceiptSource.file,
              );
            },
            child: const Text(
              '\u067e\u0631\u062f\u0627\u062e\u062a \u0628\u0627 \u0627\u0646\u062a\u062e\u0627\u0628 \u0641\u0627\u06cc\u0644',
              style: _vazirDialogStyle,
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _applyPayment(installmentIndex);
            },
            child: const Text(
              '\u067e\u0631\u062f\u0627\u062e\u062a \u0628\u062f\u0648\u0646 \u0631\u0633\u06cc\u062f',
              style: _vazirDialogStyle,
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('\u0627\u0646\u0635\u0631\u0627\u0641', style: _vazirDialogStyle),
        ),
      ),
    );
  }

  Future<void> _pickReceiptAndApplyPayment(
    int installmentIndex, {
    required _ReceiptSource source,
  }) async {
    try {
      String? receiptPath;
      if (source == _ReceiptSource.gallery) {
        final file = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        receiptPath = file?.path;
      } else if (source == _ReceiptSource.camera) {
        final file = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        receiptPath = file?.path;
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf', 'webp'],
          allowMultiple: false,
        );
        receiptPath = result?.files.single.path;
      }
      await _confirmAndApplyPayment(installmentIndex, receiptPath: receiptPath);
    } on PlatformException catch (_) {
      _showFilePickerError();
    } catch (_) {
      _showFilePickerError();
    }
  }

  void _showFilePickerError() {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          '\u062e\u0637\u0627 \u062f\u0631 \u062f\u0633\u062a\u0631\u0633\u06cc',
          style: _vazirDialogStyle,
        ),
        content: const Text(
          '\u062f\u0633\u062a\u0631\u0633\u06cc \u0628\u0647 \u06af\u0627\u0644\u0631\u06cc/\u062f\u0648\u0631\u0628\u06cc\u0646/\u0641\u0627\u06cc\u0644 \u0645\u0645\u06a9\u0646 \u0646\u06cc\u0633\u062a. \u06cc\u06a9 \u0628\u0627\u0631 \u0628\u0631\u0646\u0627\u0645\u0647 \u0631\u0627 \u06a9\u0627\u0645\u0644 \u0628\u0628\u0646\u062f\u06cc\u062f \u0648 \u062f\u0648\u0628\u0627\u0631\u0647 \u0627\u062c\u0631\u0627 \u06a9\u0646\u06cc\u062f.',
          style: _vazirDialogStyle,
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('\u0628\u0627\u0634\u0647', style: _vazirDialogStyle),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndApplyPayment(
    int installmentIndex, {
    String? receiptPath,
  }) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          '\u062a\u0627\u06cc\u06cc\u062f \u067e\u0631\u062f\u0627\u062e\u062a',
          style: _vazirDialogStyle,
        ),
        content: Column(
          children: [
            Text(
              receiptPath == null
                  ? '\u0641\u0627\u06cc\u0644\u06cc \u0627\u0646\u062a\u062e\u0627\u0628 \u0646\u0634\u062f. \u0622\u06cc\u0627 \u0627\u0632 \u067e\u0631\u062f\u0627\u062e\u062a \u0628\u062f\u0648\u0646 \u0628\u0627\u0631\u06af\u0630\u0627\u0631\u06cc \u0631\u0633\u06cc\u062f \u0645\u0637\u0645\u0626\u0646\u06cc\u062f\u061f'
                  : '\u0627\u06cc\u0646 \u0641\u0627\u06cc\u0644 \u0631\u0627 \u0627\u0646\u062a\u062e\u0627\u0628 \u06a9\u0631\u062f\u0647\u200c\u0627\u06cc\u062f. \u0622\u06cc\u0627 \u0627\u0632 \u062b\u0628\u062a \u067e\u0631\u062f\u0627\u062e\u062a \u0645\u0637\u0645\u0626\u0646\u06cc\u062f\u061f',
              style: _vazirDialogStyle,
            ),
            if (receiptPath != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Image.file(
                    File(receiptPath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('\u0627\u0646\u0635\u0631\u0627\u0641', style: _vazirDialogStyle),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              '\u062a\u0627\u06cc\u06cc\u062f \u067e\u0631\u062f\u0627\u062e\u062a',
              style: _vazirDialogStyle,
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _applyPayment(installmentIndex, receiptPath: receiptPath);
    }
  }

  void _undoPayment(int installmentIndex) {
    final paid = [..._workingInstallment.paidInstallmentIndexes]..remove(installmentIndex);
    paid.sort();
    final receiptPaths = {..._workingInstallment.installmentReceiptPaths};
    receiptPaths.remove('$installmentIndex');
    setState(() {
      _workingInstallment = _workingInstallment.copyWith(
        paidInstallmentIndexes: paid,
        installmentReceiptPaths: receiptPaths,
        remainingAmount: _calculateRemainingAmount(paid.length),
        nextPaymentDate: _calculateNextPaymentDate(paid),
      );
    });
  }

  Future<void> _confirmUndoPayment(int installmentIndex) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          '\u0644\u063a\u0648 \u067e\u0631\u062f\u0627\u062e\u062a',
          style: _vazirDialogStyle,
        ),
        content: const Text(
          '\u0622\u06cc\u0627 \u0645\u0637\u0645\u0626\u0646 \u0647\u0633\u062a\u06cc\u062f \u06a9\u0647 \u0627\u06cc\u0646 \u067e\u0631\u062f\u0627\u062e\u062a \u0644\u063a\u0648 \u0634\u0648\u062f\u061f',
          style: _vazirDialogStyle,
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('\u0627\u0646\u0635\u0631\u0627\u0641', style: _vazirDialogStyle),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              '\u0628\u0644\u0647\u060c \u0644\u063a\u0648 \u0634\u0648\u062f',
              style: _vazirDialogStyle,
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _undoPayment(installmentIndex);
    }
  }

  void _showReceiptPreview(String path) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        color: CupertinoColors.black.withValues(alpha: 0.92),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.6,
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

  void _applyPayment(int installmentIndex, {String? receiptPath}) {
    final paid = [..._workingInstallment.paidInstallmentIndexes];
    if (!paid.contains(installmentIndex)) {
      paid.add(installmentIndex);
      paid.sort();
    }

    final receiptPaths = {..._workingInstallment.installmentReceiptPaths};
    if (receiptPath != null && receiptPath.isNotEmpty) {
      receiptPaths['$installmentIndex'] = receiptPath;
    }

    final updated = _workingInstallment.copyWith(
      paidInstallmentIndexes: paid,
      installmentReceiptPaths: receiptPaths,
      remainingAmount: _calculateRemainingAmount(paid.length),
      nextPaymentDate: _calculateNextPaymentDate(paid),
    );

    setState(() {
      _workingInstallment = updated;
    });
    _playCelebration();
  }

  String _calculateRemainingAmount(int paidCount) {
    final total = _toNumber(_workingInstallment.totalAmount);
    final monthly = _toNumber(_workingInstallment.monthlyInstallmentAmount);
    final remaining = (total - (paidCount * monthly)).clamp(0, total);
    return remaining.toString();
  }

  String _calculateNextPaymentDate(List<int> paid) {
    final schedule = _buildSchedule(_workingInstallment);
    for (var i = 0; i < schedule.length; i++) {
      if (!paid.contains(i)) {
        return schedule[i].dueDate;
      }
    }
    return '\u062a\u0633\u0648\u06cc\u0647 \u0634\u062f\u0647';
  }

  Future<void> _playCelebration() async {
    setState(() => _showCelebration = true);
    await _celebrationController.forward(from: 0);
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() => _showCelebration = false);
  }

  Widget _celebrationOverlay() {
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
                width: 180,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.sparkles, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          '\u067e\u0631\u062f\u0627\u062e\u062a \u0645\u0648\u0641\u0642',
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppColors.titleText(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\u0628\u0627 \u0645\u0648\u0641\u0642\u06cc\u062a \u067e\u0631\u062f\u0627\u062e\u062a \u0634\u062f',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.bodyText(context),
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

  Future<void> _onDeletePressed() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('\u062d\u0630\u0641 \u0648\u0627\u0645', style: _vazirDialogStyle),
        content: const Text(
          '\u0622\u06cc\u0627 \u0645\u0637\u0645\u0626\u0646 \u0647\u0633\u062a\u06cc\u062f \u06a9\u0647 \u06a9\u0627\u0645\u0644 \u0627\u06cc\u0646 \u0648\u0627\u0645 \u062d\u0630\u0641 \u0634\u0648\u062f\u061f',
          style: _vazirDialogStyle,
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('\u0627\u0646\u0635\u0631\u0627\u0641', style: _vazirDialogStyle),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('\u062d\u0630\u0641 \u06a9\u0627\u0645\u0644', style: _vazirDialogStyle),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop(const InstallmentDetailsResult(deleted: true));
    }
  }

  List<_InstallmentScheduleEntry> _buildSchedule(InstallmentItem installment) {
    final items = <_InstallmentScheduleEntry>[];
    final monthlyAmount = _toNumber(installment.monthlyInstallmentAmount);
    final annualRate = installment.annualInterestPercent / 100;
    var remainingPrincipal = _toNumber(installment.totalAmount).toDouble();

    final firstDue = _parseJalali(installment.firstDueDate) ?? Jalali.now();

    for (var i = 0; i < installment.durationMonths; i++) {
      final due = firstDue.addMonths(i);
      var amount = monthlyAmount;
      if (installment.hasAnnualFee && (i + 1) % 12 == 0) {
        final yearlyInterest = (remainingPrincipal * annualRate).round();
        amount += yearlyInterest;
      }
      remainingPrincipal = (remainingPrincipal - monthlyAmount).clamp(0, double.infinity);
      items.add(
        _InstallmentScheduleEntry(
          dueDate: _jalaliToString(due),
          amount: amount,
        ),
      );
    }

    return items;
  }

  Jalali? _parseJalali(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return Jalali(y, m, d);
  }

  String _jalaliToString(Jalali date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y/$m/$d';
  }

  int _toNumber(String input) {
    final sanitized = _normalizeDigits(input).replaceAll(',', '').trim();
    return int.tryParse(sanitized) ?? 0;
  }

  String _normalizeDigits(String input) {
    const fa = '۰۱۲۳۴۵۶۷۸۹';
    const ar = '٠١٢٣٤٥٦٧٨٩';
    var out = input;
    for (var i = 0; i < 10; i++) {
      out = out.replaceAll(fa[i], '$i');
      out = out.replaceAll(ar[i], '$i');
    }
    return out;
  }

  void _popWithResult() {
    Navigator.of(context).pop(
      InstallmentDetailsResult(updatedItem: _workingInstallment),
    );
  }
}

class _InstallmentScheduleEntry {
  const _InstallmentScheduleEntry({required this.dueDate, required this.amount});

  final String dueDate;
  final num amount;
}

enum _ReceiptSource { gallery, camera, file }

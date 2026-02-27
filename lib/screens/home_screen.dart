import 'package:flutter/cupertino.dart';

import '../models/finance_items.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/installment_card.dart';
import 'installment_reports_screen.dart';
import 'installment_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.installments,
    required this.onInstallmentUpdated,
    required this.onInstallmentDeleted,
  });

  final List<InstallmentItem> installments;
  final ValueChanged<InstallmentItem> onInstallmentUpdated;
  final ValueChanged<String> onInstallmentDeleted;

  @override
  Widget build(BuildContext context) {
    final sortedInstallments = [...installments]..sort((a, b) {
      final aCompleted = a.paidInstallmentIndexes.length >= a.durationMonths;
      final bCompleted = b.paidInstallmentIndexes.length >= b.durationMonths;
      if (aCompleted != bCompleted) {
        return aCompleted ? 1 : -1;
      }
      return _dateScore(a.nextPaymentDate).compareTo(_dateScore(b.nextPaymentDate));
    });
    final nextPaymentLabel = sortedInstallments.isEmpty
        ? '\u0646\u062f\u0627\u0631\u062f'
        : sortedInstallments.first.nextPaymentDate;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          '\u0627\u0642\u0633\u0627\u0637 \u0645\u0646',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.titleText(context),
            fontFamily: 'Vazirmatn',
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            _HomeHeader(
              installmentCount: installments.length,
              nextPaymentLabel: nextPaymentLabel,
              onReportTap: () => _openReports(context),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                '\u0644\u06cc\u0633\u062a \u0627\u0642\u0633\u0627\u0637 \u0645\u0646',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.titleText(context),
                  fontFamily: 'Vazirmatn',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (installments.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  70,
                  AppSpacing.md,
                  20,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.doc_text_search,
                          size: 36,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '\u0647\u0646\u0648\u0632 \u0627\u0642\u0633\u0627\u0637\u06cc \u0628\u0631\u0627\u06cc \u0634\u0645\u0627 \u062b\u0628\u062a \u0646\u0634\u062f\u0647 \u0627\u0633\u062a.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.titleText(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\u0627\u0632 \u062f\u06a9\u0645\u0647 \u0627\u0641\u0632\u0648\u062f\u0646 \u062f\u0631 \u067e\u0627\u06cc\u06cc\u0646 \u0635\u0641\u062d\u0647\u060c \u0627\u0648\u0644\u06cc\u0646 \u0642\u0633\u0637 \u062e\u0648\u062f \u0631\u0627 \u062b\u0628\u062a \u06a9\u0646\u06cc\u062f.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 14,
                          height: 1.8,
                          color: AppColors.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...sortedInstallments.map(
                (item) => InstallmentCard(
                  title: item.title,
                  remainingAmount: item.remainingAmount,
                  nextPaymentDate: item.nextPaymentDate,
                  progressedMonths: item.paidInstallmentIndexes.length,
                  totalMonths: item.durationMonths,
                  onTap: () {
                    _openDetails(context, item);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetails(
    BuildContext context,
    InstallmentItem installment,
  ) async {
    final result = await Navigator.of(context).push<InstallmentDetailsResult>(
      CupertinoPageRoute<InstallmentDetailsResult>(
        builder: (_) => InstallmentDetailsScreen(installment: installment),
      ),
    );
    if (result == null) return;
    if (result.deleted) {
      onInstallmentDeleted(installment.id);
      return;
    }
    if (result.updatedItem != null) {
      onInstallmentUpdated(result.updatedItem!);
    }
  }

  void _openReports(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => InstallmentReportsScreen(installments: installments),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.installmentCount,
    required this.nextPaymentLabel,
    required this.onReportTap,
  });

  final int installmentCount;
  final String nextPaymentLabel;
  final VoidCallback onReportTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
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
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    CupertinoIcons.chart_bar_alt_fill,
                    color: CupertinoColors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text(
                    '\u0645\u062f\u06cc\u0631\u06cc\u062a \u0647\u0648\u0634\u0645\u0646\u062f \u0627\u0642\u0633\u0627\u0637',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  color: const Color(0x26FFFFFF),
                  borderRadius: BorderRadius.circular(10),
                  onPressed: onReportTap,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.chart_pie_fill,
                        size: 14,
                        color: CupertinoColors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '\u06af\u0632\u0627\u0631\u0634',
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _HeaderStat(
                    title: '\u062a\u0639\u062f\u0627\u062f \u0627\u0642\u0633\u0627\u0637',
                    value: '$installmentCount \u0645\u0648\u0631\u062f',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _HeaderStat(
                    title: '\u067e\u0631\u062f\u0627\u062e\u062a \u0628\u0639\u062f\u06cc',
                    value: nextPaymentLabel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

int _dateScore(String value) {
  final parts = value.split('/');
  if (parts.length != 3) return 99999999;
  final y = int.tryParse(parts[0]) ?? 9999;
  final m = int.tryParse(parts[1]) ?? 12;
  final d = int.tryParse(parts[2]) ?? 31;
  return (y * 10000) + (m * 100) + d;
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 12,
              color: Color(0xCCFFFFFF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../models/finance_items.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'check_details_screen.dart';

class MyChecksScreen extends StatelessWidget {
  const MyChecksScreen({
    super.key,
    required this.checks,
    required this.onCheckDeleted,
    required this.onCheckUpdated,
  });

  final List<CheckItem> checks;
  final ValueChanged<String> onCheckDeleted;
  final ValueChanged<CheckItem> onCheckUpdated;

  @override
  Widget build(BuildContext context) {
    final sortedChecks = [...checks]..sort((a, b) {
      if (a.isSettled != b.isSettled) {
        return a.isSettled ? 1 : -1;
      }
      return _dateScore(a.dueDate).compareTo(_dateScore(b.dueDate));
    });
    final firstDue = sortedChecks.isEmpty
        ? '\u0646\u062f\u0627\u0631\u062f'
        : sortedChecks.first.dueDate;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          '\u0686\u06a9 \u0647\u0627\u06cc \u0645\u0646',
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
            _ChecksHeader(checkCount: checks.length, firstDueDate: firstDue),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                '\u0644\u06cc\u0633\u062a \u0686\u06a9 \u0647\u0627',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.titleText(context),
                  fontFamily: 'Vazirmatn',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (sortedChecks.isEmpty)
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
                          color: AppColors.checksAccent.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.doc_on_doc,
                          size: 36,
                          color: AppColors.checksAccent,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '\u0647\u0646\u0648\u0632 \u0686\u06a9\u06cc \u0628\u0631\u0627\u06cc \u0634\u0645\u0627 \u062b\u0628\u062a \u0646\u0634\u062f\u0647 \u0627\u0633\u062a.',
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
                        '\u0627\u0632 \u062f\u06a9\u0645\u0647 \u0627\u0641\u0632\u0648\u062f\u0646 \u062f\u0631 \u067e\u0627\u06cc\u06cc\u0646 \u0635\u0641\u062d\u0647\u060c \u0627\u0648\u0644\u06cc\u0646 \u0686\u06a9 \u062e\u0648\u062f \u0631\u0627 \u062b\u0628\u062a \u06a9\u0646\u06cc\u062f.',
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
              ...sortedChecks.map(
                (item) => _CheckCard(
                  item: item,
                  title: item.title,
                  amount: item.amount,
                  dueDate: item.dueDate,
                  counterparty: item.counterparty,
                  checkType: item.checkType,
                  onCheckDeleted: onCheckDeleted,
                  onCheckUpdated: onCheckUpdated,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChecksHeader extends StatelessWidget {
  const _ChecksHeader({required this.checkCount, required this.firstDueDate});

  final int checkCount;
  final String firstDueDate;

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
            colors: [Color(0xFF30B28C), Color(0xFF0E8D68)],
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
                    CupertinoIcons.doc_on_clipboard_fill,
                    color: CupertinoColors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text(
                    '\u0645\u062f\u06cc\u0631\u06cc\u062a \u062d\u0631\u0641\u0647 \u0627\u06cc \u0686\u06a9 \u0647\u0627',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _HeaderStat(
                    title: '\u062a\u0639\u062f\u0627\u062f \u0686\u06a9 \u0647\u0627',
                    value: '$checkCount \u0645\u0648\u0631\u062f',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _HeaderStat(
                    title: '\u0627\u0648\u0644\u06cc\u0646 \u0633\u0631\u0631\u0633\u06cc\u062f',
                    value: firstDueDate,
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
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 12,
                color: Color(0xCCFFFFFF),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckCard extends StatelessWidget {
  const _CheckCard({
    required this.item,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.counterparty,
    required this.checkType,
    required this.onCheckDeleted,
    required this.onCheckUpdated,
  });

  final CheckItem item;
  final String title;
  final String amount;
  final String dueDate;
  final String counterparty;
  final String checkType;
  final ValueChanged<String> onCheckDeleted;
  final ValueChanged<CheckItem> onCheckUpdated;

  @override
  Widget build(BuildContext context) {
    final isReceived = checkType == 'received';
    final money = int.tryParse(amount) ?? 0;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push<CheckDetailsResult>(
          CupertinoPageRoute<CheckDetailsResult>(
            builder: (_) => CheckDetailsScreen(item: item),
          ),
        );
        if (result?.deleted == true) {
          onCheckDeleted(item.id);
        }
        if (result?.updatedItem != null) {
          onCheckUpdated(result!.updatedItem!);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.sectionBackground(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider(context), width: 0.7),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow(context),
              blurRadius: 10,
              offset: const Offset(0, 5),
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
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.titleText(context),
                      fontFamily: 'Vazirmatn',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isReceived
                            ? AppColors.checksAccent
                            : CupertinoColors.systemOrange)
                        .withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isReceived
                        ? '\u062f\u0631\u06cc\u0627\u0641\u062a\u06cc'
                        : '\u067e\u0631\u062f\u0627\u062e\u062a\u06cc',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isReceived
                          ? AppColors.checksAccent
                          : CupertinoColors.systemOrange,
                      fontFamily: 'Vazirmatn',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '\u0645\u0628\u0644\u063a \u0686\u06a9: ${NumberFormat('#,###').format(money)} \u062a\u0648\u0645\u0627\u0646',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.bodyText(context),
                fontFamily: 'Vazirmatn',
              ),
            ),
            const SizedBox(height: 3),
            Text(
              counterparty,
              style: TextStyle(
                fontSize: 12.3,
                color: AppColors.secondaryText(context),
                fontFamily: 'Vazirmatn',
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  size: 14,
                  color: AppColors.secondaryText(context),
                ),
                const SizedBox(width: 5),
              Text(
                '\u0633\u0631\u0631\u0633\u06cc\u062f: $dueDate',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText(context),
                  fontFamily: 'Vazirmatn',
                ),
              ),
              const Spacer(),
              if (item.isSettled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeGreen.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isReceived
                        ? '\u2713 \u062f\u0631\u06cc\u0627\u0641\u062a \u0634\u062f'
                        : '\u2713 \u067e\u0631\u062f\u0627\u062e\u062a \u0634\u062f',
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.activeGreen,
                    ),
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
  final p = value.split('/');
  if (p.length != 3) return 99999999;
  final y = int.tryParse(p[0]) ?? 9999;
  final m = int.tryParse(p[1]) ?? 12;
  final d = int.tryParse(p[2]) ?? 31;
  return (y * 10000) + (m * 100) + d;
}

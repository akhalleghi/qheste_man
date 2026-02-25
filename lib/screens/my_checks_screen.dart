import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class MyChecksScreen extends StatelessWidget {
  const MyChecksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final checks = [
      const CheckItem(
        title: 'چک اجاره دفتر',
        amount: '۹,۵۰۰,۰۰۰',
        dueDate: '۱۴۰۴/۱۲/۱۰',
      ),
      const CheckItem(
        title: 'چک تامین تجهیزات',
        amount: '۶,۲۰۰,۰۰۰',
        dueDate: '۱۴۰۴/۱۲/۲۰',
      ),
      const CheckItem(
        title: 'چک خرید اقساطی',
        amount: '۱۴,۰۰۰,۰۰۰',
        dueDate: '۱۴۰۵/۰۱/۰۸',
      ),
    ];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'چک های من',
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
            _ChecksHeader(checkCount: checks.length),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'لیست چک ها',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.titleText(context),
                  fontFamily: 'Vazirmatn',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...checks.map(
              (item) => _CheckCard(
                title: item.title,
                amount: item.amount,
                dueDate: item.dueDate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecksHeader extends StatelessWidget {
  const _ChecksHeader({required this.checkCount});

  final int checkCount;

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
                    'مدیریت حرفه ای چک ها',
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
                    title: 'تعداد چک ها',
                    value: '$checkCount مورد',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: _HeaderStat(
                    title: 'سررسید نزدیک',
                    value: '۱۰ اسفند',
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

class _CheckCard extends StatelessWidget {
  const _CheckCard({
    required this.title,
    required this.amount,
    required this.dueDate,
  });

  final String title;
  final String amount;
  final String dueDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.sectionBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow(context),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.titleText(context),
              fontFamily: 'Vazirmatn',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'مبلغ چک: $amount تومان',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.bodyText(context),
              fontFamily: 'Vazirmatn',
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                CupertinoIcons.calendar,
                size: 16,
                color: AppColors.secondaryText(context),
              ),
              const SizedBox(width: 6),
              Text(
                'تاریخ سررسید: $dueDate',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText(context),
                  fontFamily: 'Vazirmatn',
                ),
              ),
              const Spacer(),
              Icon(
                CupertinoIcons.clock,
                size: 16,
                color: AppColors.secondaryText(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CheckItem {
  const CheckItem({
    required this.title,
    required this.amount,
    required this.dueDate,
  });

  final String title;
  final String amount;
  final String dueDate;
}

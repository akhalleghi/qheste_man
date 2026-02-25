import 'package:flutter/cupertino.dart';

import '../data/app_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/installment_card.dart';
import 'installment_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final installments = AppData.installments;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'اقساط من',
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
            _HomeHeader(installmentCount: installments.length),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'لیست اقساط من',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.titleText(context),
                  fontFamily: 'Vazirmatn',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...installments.map(
              (item) => InstallmentCard(
                title: item.title,
                remainingAmount: item.remainingAmount,
                nextPaymentDate: item.nextPaymentDate,
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (_) => InstallmentDetailsScreen(
                        title: item.title,
                        remainingAmount: item.remainingAmount,
                        nextPaymentDate: item.nextPaymentDate,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.installmentCount});

  final int installmentCount;

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
                    'مدیریت هوشمند اقساط',
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
                    title: 'تعداد اقساط',
                    value: '$installmentCount مورد',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: _HeaderStat(title: 'پرداخت بعدی', value: '۱۵ اسفند'),
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

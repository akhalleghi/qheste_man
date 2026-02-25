import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/ios_section.dart';

class InstallmentDetailsScreen extends StatelessWidget {
  const InstallmentDetailsScreen({
    super.key,
    required this.title,
    required this.remainingAmount,
    required this.nextPaymentDate,
  });

  final String title;
  final String remainingAmount;
  final String nextPaymentDate;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          color: AppColors.primary,
        ),
        previousPageTitle: 'خانه',
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'جزئیات $title',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.titleText(context),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            IosSection(
              title: 'اطلاعات کلی',
              children: [
                _infoRow(context, 'عنوان', title),
                _infoRow(context, 'مبلغ باقی\u200cمانده', '$remainingAmount تومان'),
                _infoRow(context, 'تاریخ پرداخت بعدی', nextPaymentDate),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            IosSection(
              title: 'برنامه پرداخت',
              children: const [
                _PaymentRow(
                  date: '۱۴۰۴/۱۲/۱۵',
                  amount: '۲,۰۰۰,۰۰۰ تومان',
                  status: 'در انتظار',
                ),
                _PaymentRow(
                  date: '۱۴۰۵/۰۱/۱۵',
                  amount: '۲,۰۰۰,۰۰۰ تومان',
                  status: 'در انتظار',
                ),
                _PaymentRow(
                  date: '۱۴۰۵/۰۲/۱۵',
                  amount: '۲,۰۰۰,۰۰۰ تومان',
                  status: 'در انتظار',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: CupertinoButton.filled(
                onPressed: () {},
                borderRadius: BorderRadius.circular(12),
                child: const Text('ثبت پرداخت'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String title, String value) {
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
                fontSize: 14,
                color: AppColors.secondaryText(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.bodyText(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.date,
    required this.amount,
    required this.status,
  });

  final String date;
  final String amount;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              date,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.bodyText(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              amount,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.bodyText(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              status,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class InstallmentCard extends StatelessWidget {
  const InstallmentCard({
    super.key,
    required this.title,
    required this.remainingAmount,
    required this.nextPaymentDate,
    required this.onTap,
  });

  final String title;
  final String remainingAmount;
  final String nextPaymentDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.sectionBackground(context),
          borderRadius: BorderRadius.circular(AppRadius.card),
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
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.titleText(context),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'مبلغ باقی\u200cمانده: $remainingAmount تومان',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.bodyText(context),
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
                  'پرداخت بعدی: $nextPaymentDate',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText(context),
                  ),
                ),
                const Spacer(),
                Icon(
                  CupertinoIcons.chevron_back,
                  size: 16,
                  color: AppColors.secondaryText(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

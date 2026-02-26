import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class InstallmentCard extends StatelessWidget {
  const InstallmentCard({
    super.key,
    required this.title,
    required this.remainingAmount,
    required this.nextPaymentDate,
    required this.progressedMonths,
    required this.totalMonths,
    required this.onTap,
  });

  final String title;
  final String remainingAmount;
  final String nextPaymentDate;
  final int progressedMonths;
  final int totalMonths;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formattedRemaining = _formatAmount(remainingAmount);
    final total = totalMonths <= 0 ? 1 : totalMonths;
    final done = progressedMonths.clamp(0, total);
    final progress = done / total;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.sectionBackground(context),
              AppColors.sectionBackground(context).withValues(alpha: 0.92),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider(context), width: 0.7),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow(context),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.22),
                    AppColors.primary.withValues(alpha: 0.06),
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CustomPaint(
                      painter: _RingPainter(
                        progress: progress,
                        trackColor: AppColors.divider(context),
                        progressColor: AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    '$done',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.titleText(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.titleText(context),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '\u0645\u0628\u0644\u063a \u0628\u0627\u0642\u06cc\u200c\u0645\u0627\u0646\u062f\u0647: $formattedRemaining \u062a\u0648\u0645\u0627\u0646',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.bodyText(context),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$done \u0627\u0632 $total \u0645\u0627\u0647',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.divider(context),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FractionallySizedBox(
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.calendar,
                        size: 14,
                        color: AppColors.secondaryText(context),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '\u067e\u0631\u062f\u0627\u062e\u062a \u0628\u0639\u062f\u06cc: $nextPaymentDate',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              CupertinoIcons.chevron_back,
              size: 16,
              color: AppColors.secondaryText(context),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(String raw) {
    final normalized = _normalizeDigits(raw).replaceAll(',', '').trim();
    final parsed = int.tryParse(normalized);
    if (parsed == null) return raw;
    return NumberFormat('#,###').format(parsed);
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
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 4.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final active = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, active);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}


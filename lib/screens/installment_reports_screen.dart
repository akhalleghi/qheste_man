import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../models/finance_items.dart';
import '../theme/app_colors.dart';

class InstallmentReportsScreen extends StatelessWidget {
  const InstallmentReportsScreen({super.key, required this.installments});

  final List<InstallmentItem> installments;

  @override
  Widget build(BuildContext context) {
    final report = _InstallmentReport.from(installments);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: const CupertinoNavigationBarBackButton(color: AppColors.primary),
        middle: Text(
          '\u06af\u0632\u0627\u0631\u0634 \u0627\u0642\u0633\u0627\u0637',
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontWeight: FontWeight.w700,
            color: AppColors.titleText(context),
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
          children: [
            _SummaryHeader(report: report),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: '\u067e\u0631\u062f\u0627\u062e\u062a\u200c\u0634\u062f\u0647 \u062a\u0627\u06a9\u0646\u0648\u0646',
                    value: _money(report.totalPaid),
                    accent: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    title: '\u0628\u062f\u0647\u06cc \u0628\u0627\u0642\u06cc\u200c\u0645\u0627\u0646\u062f\u0647',
                    value: _money(report.totalRemaining),
                    accent: CupertinoColors.systemRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: '\u0645\u06cc\u0627\u0646\u06af\u06cc\u0646 \u0645\u0628\u0644\u063a \u0647\u0631 \u0642\u0633\u0637',
                    value: _money(report.avgInstallmentAmount),
                    accent: AppColors.checksAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    title: '\u0627\u0642\u0633\u0627\u0637 \u0633\u0631\u0631\u0633\u06cc\u062f \u0646\u0632\u062f\u06cc\u06a9 (\u06f3\u06f0 \u0631\u0648\u0632)',
                    value: '${report.nearDueCount} \u0645\u0648\u0631\u062f',
                    accent: CupertinoColors.systemOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: '\u0646\u0633\u0628\u062a \u067e\u0631\u062f\u0627\u062e\u062a \u0628\u0647 \u0628\u062f\u0647\u06cc',
              child: _PieAndLegend(
                centerLabel: '${(report.paidAmountRatio * 100).round()}%',
                segments: [
                  _PieSegment(
                    label: '\u067e\u0631\u062f\u0627\u062e\u062a\u200c\u0634\u062f\u0647',
                    value: report.totalPaid,
                    color: AppColors.primary,
                  ),
                  _PieSegment(
                    label: '\u0628\u0627\u0642\u06cc\u200c\u0645\u0627\u0646\u062f\u0647',
                    value: report.totalRemaining,
                    color: CupertinoColors.systemRed,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '\u0627\u0642\u0633\u0627\u0637 \u067e\u0631\u062f\u0627\u062e\u062a\u200c\u0634\u062f\u0647 \u062f\u0631 \u0628\u0631\u0627\u0628\u0631 \u0628\u0627\u0642\u06cc',
              child: _PieAndLegend(
                centerLabel: '${(report.installmentProgressRatio * 100).round()}%',
                segments: [
                  _PieSegment(
                    label: '\u0645\u0627\u0647 \u067e\u0631\u062f\u0627\u062e\u062a\u200c\u0634\u062f\u0647',
                    value: report.totalPaidMonths.toDouble(),
                    color: AppColors.checksAccent,
                  ),
                  _PieSegment(
                    label: '\u0645\u0627\u0647 \u0628\u0627\u0642\u06cc\u200c\u0645\u0627\u0646\u062f\u0647',
                    value: (report.totalMonths - report.totalPaidMonths).toDouble(),
                    color: CupertinoColors.systemGrey,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '\u0648\u0636\u0639\u06cc\u062a \u06a9\u0644\u06cc \u0648\u0627\u0645\u200c\u0647\u0627',
              child: _PieAndLegend(
                centerLabel: '${(report.completedLoanRatio * 100).round()}%',
                segments: [
                  _PieSegment(
                    label: '\u062a\u0633\u0648\u06cc\u0647\u200c\u0634\u062f\u0647',
                    value: report.completedLoans.toDouble(),
                    color: CupertinoColors.activeGreen,
                  ),
                  _PieSegment(
                    label: '\u062f\u0631 \u062d\u0627\u0644 \u067e\u0631\u062f\u0627\u062e\u062a',
                    value: report.activeLoans.toDouble(),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '\u062a\u0648\u0632\u06cc\u0639 \u0645\u0648\u0633\u0633\u0647\u200c\u0647\u0627\u06cc \u0648\u0627\u0645 \u0628\u0647 \u062a\u0631\u062a\u06cc\u0628 \u062a\u0639\u062f\u0627\u062f',
              child: Column(
                children: report.lenderItems.isEmpty
                    ? [
                        Text(
                          '\u062f\u0627\u062f\u0647\u200c\u0627\u06cc \u0628\u0631\u0627\u06cc \u0646\u0645\u0627\u06cc\u0634 \u0648\u062c\u0648\u062f \u0646\u062f\u0627\u0631\u062f.',
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            color: AppColors.bodyText(context),
                          ),
                        ),
                      ]
                    : report.lenderItems
                        .map(
                          (item) => _LenderBar(
                            name: item.name,
                            count: item.count,
                            ratio: report.maxLenderCount == 0
                                ? 0
                                : item.count / report.maxLenderCount,
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _money(double value) {
    final safe = value.isNaN || value.isInfinite ? 0 : value;
    return '${NumberFormat('#,###').format(safe.round())} \u062a\u0648\u0645\u0627\u0646';
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.report});

  final _InstallmentReport report;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
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
                  CupertinoIcons.chart_pie_fill,
                  color: CupertinoColors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '\u06af\u0632\u0627\u0631\u0634 \u06a9\u0644\u06cc \u0648\u0627\u0645\u200c\u0647\u0627 \u0648 \u0627\u0642\u0633\u0627\u0637',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HeaderStat(
                  title: '\u062a\u0639\u062f\u0627\u062f \u0648\u0627\u0645\u200c\u0647\u0627',
                  value: '${report.totalLoans} \u0645\u0648\u0631\u062f',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeaderStat(
                  title: '\u062a\u0633\u0648\u06cc\u0647\u200c\u0634\u062f\u0647',
                  value: '${report.completedLoans} \u0648\u0627\u0645',
                ),
              ),
            ],
          ),
        ],
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.accent,
  });

  final String title;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.sectionBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider(context), width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 12.5,
              color: AppColors.secondaryText(context),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontWeight: FontWeight.w800,
              fontSize: 14.5,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sectionBackground(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider(context), width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.titleText(context),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _PieAndLegend extends StatelessWidget {
  const _PieAndLegend({
    required this.centerLabel,
    required this.segments,
  });

  final String centerLabel;
  final List<_PieSegment> segments;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PieChart(
          centerLabel: centerLabel,
          segments: segments,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: segments.map((segment) {
              final total = segments.fold<double>(0, (s, e) => s + e.value);
              final ratio = total == 0 ? 0 : (segment.value / total) * 100;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: segment.color,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        segment.label,
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 12.5,
                          color: AppColors.bodyText(context),
                        ),
                      ),
                    ),
                    Text(
                      '${ratio.round()}%',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.titleText(context),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PieChart extends StatelessWidget {
  const _PieChart({required this.centerLabel, required this.segments});

  final String centerLabel;
  final List<_PieSegment> segments;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(130, 130),
            painter: _PiePainter(segments: segments),
          ),
          Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sectionBackground(context),
              border: Border.all(color: AppColors.divider(context), width: 0.7),
            ),
            child: Text(
              centerLabel,
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.titleText(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter({required this.segments});

  final List<_PieSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final total = segments.fold<double>(0, (s, e) => s + e.value);
    if (total <= 0) {
      final p = Paint()..color = const Color(0x22000000);
      canvas.drawCircle(center, radius, p);
      return;
    }

    var start = -math.pi / 2;
    for (final segment in segments) {
      final sweep = (segment.value / total) * math.pi * 2;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round
        ..color = segment.color;
      canvas.drawArc(rect.deflate(11), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) => true;
}

class _LenderBar extends StatelessWidget {
  const _LenderBar({
    required this.name,
    required this.count,
    required this.ratio,
  });

  final String name;
  final int count;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 12.5,
                color: AppColors.bodyText(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.divider(context),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: ratio.clamp(0.0, 1.0),
                  child: Container(
                    height: 9,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0A84FF), Color(0xFF30B28C)],
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.titleText(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _PieSegment {
  const _PieSegment({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class _InstallmentReport {
  const _InstallmentReport({
    required this.totalLoans,
    required this.activeLoans,
    required this.completedLoans,
    required this.totalAmount,
    required this.totalRemaining,
    required this.totalPaid,
    required this.paidAmountRatio,
    required this.totalMonths,
    required this.totalPaidMonths,
    required this.installmentProgressRatio,
    required this.avgInstallmentAmount,
    required this.nearDueCount,
    required this.lenderItems,
    required this.maxLenderCount,
    required this.completedLoanRatio,
  });

  final int totalLoans;
  final int activeLoans;
  final int completedLoans;
  final double totalAmount;
  final double totalRemaining;
  final double totalPaid;
  final double paidAmountRatio;
  final int totalMonths;
  final int totalPaidMonths;
  final double installmentProgressRatio;
  final double avgInstallmentAmount;
  final int nearDueCount;
  final List<_LenderCount> lenderItems;
  final int maxLenderCount;
  final double completedLoanRatio;

  factory _InstallmentReport.from(List<InstallmentItem> items) {
    var totalAmount = 0.0;
    var totalRemaining = 0.0;
    var totalMonths = 0;
    var totalPaidMonths = 0;
    var activeLoans = 0;
    var completedLoans = 0;
    var nearDueCount = 0;

    final lenderMap = <String, int>{};
    final now = DateTime.now();

    for (final item in items) {
      final total = _num(item.totalAmount);
      final rem = _num(item.remainingAmount).clamp(0, total);
      final paidMonths = item.paidInstallmentIndexes.length.clamp(0, item.durationMonths);
      final completed = paidMonths >= item.durationMonths && item.durationMonths > 0;

      totalAmount += total;
      totalRemaining += rem;
      totalMonths += item.durationMonths;
      totalPaidMonths += paidMonths;
      if (completed) {
        completedLoans += 1;
      } else {
        activeLoans += 1;
      }

      final due = _jalaliToDate(item.nextPaymentDate);
      if (due != null) {
        final days = due.difference(now).inDays;
        if (days >= 0 && days <= 30) nearDueCount += 1;
      }

      final lender = item.lenderName.trim().isEmpty
          ? '\u0646\u0627\u0645\u0634\u062e\u0635'
          : item.lenderName.trim();
      lenderMap[lender] = (lenderMap[lender] ?? 0) + 1;
    }

    final paid = (totalAmount - totalRemaining)
        .clamp(0, double.infinity)
        .toDouble();
    final paidRatio = totalAmount <= 0 ? 0.0 : paid / totalAmount;
    final progressRatio = totalMonths <= 0 ? 0.0 : totalPaidMonths / totalMonths;
    final completedRatio = items.isEmpty ? 0.0 : completedLoans / items.length;

    final lenders = lenderMap.entries
        .map((e) => _LenderCount(name: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final topLenders = lenders.take(6).toList();
    final maxLender = topLenders.isEmpty ? 0 : topLenders.first.count;

    return _InstallmentReport(
      totalLoans: items.length,
      activeLoans: activeLoans,
      completedLoans: completedLoans,
      totalAmount: totalAmount,
      totalRemaining: totalRemaining,
      totalPaid: paid,
      paidAmountRatio: paidRatio,
      totalMonths: totalMonths,
      totalPaidMonths: totalPaidMonths,
      installmentProgressRatio: progressRatio,
      avgInstallmentAmount: items.isEmpty
          ? 0
          : items.fold<double>(0, (s, e) => s + _num(e.monthlyInstallmentAmount)) / items.length,
      nearDueCount: nearDueCount,
      lenderItems: topLenders,
      maxLenderCount: maxLender,
      completedLoanRatio: completedRatio,
    );
  }

  static double _num(String value) {
    final normalized = _normalizeDigits(value).replaceAll(',', '').trim();
    return double.tryParse(normalized) ?? 0;
  }

  static String _normalizeDigits(String input) {
    const fa = '۰۱۲۳۴۵۶۷۸۹';
    const ar = '٠١٢٣٤٥٦٧٨٩';
    var out = input;
    for (var i = 0; i < 10; i++) {
      out = out.replaceAll(fa[i], '$i');
      out = out.replaceAll(ar[i], '$i');
    }
    return out;
  }

  static DateTime? _jalaliToDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;
    final y = int.tryParse(_normalizeDigits(parts[0]));
    final m = int.tryParse(_normalizeDigits(parts[1]));
    final d = int.tryParse(_normalizeDigits(parts[2]));
    if (y == null || m == null || d == null) return null;
    try {
      return Jalali(y, m, d).toDateTime();
    } catch (_) {
      return null;
    }
  }
}

class _LenderCount {
  const _LenderCount({required this.name, required this.count});
  final String name;
  final int count;
}

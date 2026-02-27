import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../models/finance_items.dart';
import '../theme/app_colors.dart';

class CheckReportsScreen extends StatelessWidget {
  const CheckReportsScreen({super.key, required this.checks});

  final List<CheckItem> checks;

  @override
  Widget build(BuildContext context) {
    final report = _CheckReport.from(checks);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: const CupertinoNavigationBarBackButton(color: AppColors.primary),
        middle: Text(
          '\u06af\u0632\u0627\u0631\u0634 \u0686\u06a9\u200c\u0647\u0627',
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
                    title: '\u0645\u062c\u0645\u0648\u0639 \u0645\u0628\u0644\u063a \u062a\u0633\u0648\u06cc\u0647\u200c\u0634\u062f\u0647',
                    value: _money(report.settledAmount),
                    accent: CupertinoColors.activeGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    title: '\u0645\u062c\u0645\u0648\u0639 \u0645\u0628\u0644\u063a \u0628\u0627\u0642\u06cc\u200c\u0645\u0627\u0646\u062f\u0647',
                    value: _money(report.unsettledAmount),
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
                    title: '\u0686\u06a9\u200c\u0647\u0627\u06cc \u0633\u0631\u0631\u0633\u06cc\u062f \u0646\u0632\u062f\u06cc\u06a9 (\u06f3\u06f0 \u0631\u0648\u0632)',
                    value: '${report.nearDueCount} \u0645\u0648\u0631\u062f',
                    accent: CupertinoColors.systemOrange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    title: '\u0645\u06cc\u0627\u0646\u06af\u06cc\u0646 \u0645\u0628\u0644\u063a \u0647\u0631 \u0686\u06a9',
                    value: _money(report.avgAmount),
                    accent: AppColors.checksAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: '\u0646\u0633\u0628\u062a \u062a\u0633\u0648\u06cc\u0647 \u0645\u0628\u0644\u063a\u06cc',
              child: _PieAndLegend(
                centerLabel: '${(report.settledAmountRatio * 100).round()}%',
                segments: [
                  _PieSegment(
                    label: '\u062a\u0633\u0648\u06cc\u0647\u200c\u0634\u062f\u0647',
                    value: report.settledAmount,
                    color: CupertinoColors.activeGreen,
                  ),
                  _PieSegment(
                    label: '\u0628\u0627\u0642\u06cc\u200c\u0645\u0627\u0646\u062f\u0647',
                    value: report.unsettledAmount,
                    color: CupertinoColors.systemRed,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '\u0648\u0636\u0639\u06cc\u062a \u062a\u0639\u062f\u0627\u062f \u0686\u06a9\u200c\u0647\u0627',
              child: _PieAndLegend(
                centerLabel: '${(report.settledCountRatio * 100).round()}%',
                segments: [
                  _PieSegment(
                    label: '\u062a\u0633\u0648\u06cc\u0647\u200c\u0634\u062f\u0647',
                    value: report.settledCount.toDouble(),
                    color: CupertinoColors.activeGreen,
                  ),
                  _PieSegment(
                    label: '\u062f\u0631 \u0627\u0646\u062a\u0638\u0627\u0631 \u062a\u0633\u0648\u06cc\u0647',
                    value: report.unsettledCount.toDouble(),
                    color: AppColors.checksAccent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '\u062f\u0631\u06cc\u0627\u0641\u062a\u06cc \u062f\u0631 \u0628\u0631\u0627\u0628\u0631 \u067e\u0631\u062f\u0627\u062e\u062a\u06cc (\u0645\u0628\u0644\u063a)',
              child: _PieAndLegend(
                centerLabel: '${(report.receivedAmountRatio * 100).round()}%',
                segments: [
                  _PieSegment(
                    label: '\u062f\u0631\u06cc\u0627\u0641\u062a\u06cc',
                    value: report.receivedAmount,
                    color: AppColors.checksAccent,
                  ),
                  _PieSegment(
                    label: '\u067e\u0631\u062f\u0627\u062e\u062a\u06cc',
                    value: report.paidAmount,
                    color: CupertinoColors.systemOrange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '\u062a\u0648\u0632\u06cc\u0639 \u0628\u0627\u0646\u06a9\u200c\u0647\u0627 (\u0628\u0631 \u0627\u0633\u0627\u0633 \u062a\u0639\u062f\u0627\u062f)',
              child: Column(
                children: report.bankItems.isEmpty
                    ? [
                        Text(
                          '\u062f\u0627\u062f\u0647\u200c\u0627\u06cc \u0628\u0631\u0627\u06cc \u0646\u0645\u0627\u06cc\u0634 \u0648\u062c\u0648\u062f \u0646\u062f\u0627\u0631\u062f.',
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            color: AppColors.bodyText(context),
                          ),
                        ),
                      ]
                    : report.bankItems
                        .map(
                          (item) => _BankBar(
                            name: item.name,
                            count: item.count,
                            ratio: report.maxBankCount == 0
                                ? 0
                                : item.count / report.maxBankCount,
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

  final _CheckReport report;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
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
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '\u06af\u0632\u0627\u0631\u0634 \u06a9\u0627\u0645\u0644 \u0648\u0636\u0639\u06cc\u062a \u0686\u06a9\u200c\u0647\u0627',
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
                  title: '\u06a9\u0644 \u0686\u06a9\u200c\u0647\u0627',
                  value: '${report.totalChecks} \u0645\u0648\u0631\u062f',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeaderStat(
                  title: '\u062a\u0633\u0648\u06cc\u0647\u200c\u0634\u062f\u0647',
                  value: '${report.settledCount} \u0645\u0648\u0631\u062f',
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
        _PieChart(centerLabel: centerLabel, segments: segments),
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

class _BankBar extends StatelessWidget {
  const _BankBar({
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
                        colors: [Color(0xFF30B28C), Color(0xFF0E8D68)],
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

class _CheckReport {
  const _CheckReport({
    required this.totalChecks,
    required this.settledCount,
    required this.unsettledCount,
    required this.totalAmount,
    required this.settledAmount,
    required this.unsettledAmount,
    required this.avgAmount,
    required this.nearDueCount,
    required this.receivedAmount,
    required this.paidAmount,
    required this.settledAmountRatio,
    required this.settledCountRatio,
    required this.receivedAmountRatio,
    required this.bankItems,
    required this.maxBankCount,
  });

  final int totalChecks;
  final int settledCount;
  final int unsettledCount;
  final double totalAmount;
  final double settledAmount;
  final double unsettledAmount;
  final double avgAmount;
  final int nearDueCount;
  final double receivedAmount;
  final double paidAmount;
  final double settledAmountRatio;
  final double settledCountRatio;
  final double receivedAmountRatio;
  final List<_BankCount> bankItems;
  final int maxBankCount;

  factory _CheckReport.from(List<CheckItem> checks) {
    var settledCount = 0;
    var unsettledCount = 0;
    var totalAmount = 0.0;
    var settledAmount = 0.0;
    var unsettledAmount = 0.0;
    var nearDueCount = 0;
    var receivedAmount = 0.0;
    var paidAmount = 0.0;

    final now = DateTime.now();
    final bankMap = <String, int>{};

    for (final item in checks) {
      final amount = _num(item.amount);
      totalAmount += amount;
      if (item.isSettled) {
        settledCount += 1;
        settledAmount += amount;
      } else {
        unsettledCount += 1;
        unsettledAmount += amount;
      }

      if (item.checkType == 'received') {
        receivedAmount += amount;
      } else {
        paidAmount += amount;
      }

      final due = _jalaliToDate(item.dueDate);
      if (due != null) {
        final days = due.difference(now).inDays;
        if (!item.isSettled && days >= 0 && days <= 30) nearDueCount += 1;
      }

      final bank = item.bankName.trim().isEmpty
          ? '\u0646\u0627\u0645\u0634\u062e\u0635'
          : item.bankName.trim();
      bankMap[bank] = (bankMap[bank] ?? 0) + 1;
    }

    final settledAmountRatio = totalAmount <= 0 ? 0.0 : settledAmount / totalAmount;
    final settledCountRatio = checks.isEmpty ? 0.0 : settledCount / checks.length;
    final receivedAmountRatio = (receivedAmount + paidAmount) <= 0
        ? 0.0
        : receivedAmount / (receivedAmount + paidAmount);

    final banks = bankMap.entries
        .map((e) => _BankCount(name: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    final topBanks = banks.take(6).toList();
    final maxBankCount = topBanks.isEmpty ? 0 : topBanks.first.count;

    return _CheckReport(
      totalChecks: checks.length,
      settledCount: settledCount,
      unsettledCount: unsettledCount,
      totalAmount: totalAmount,
      settledAmount: settledAmount,
      unsettledAmount: unsettledAmount,
      avgAmount: checks.isEmpty ? 0 : totalAmount / checks.length,
      nearDueCount: nearDueCount,
      receivedAmount: receivedAmount,
      paidAmount: paidAmount,
      settledAmountRatio: settledAmountRatio,
      settledCountRatio: settledCountRatio,
      receivedAmountRatio: receivedAmountRatio,
      bankItems: topBanks,
      maxBankCount: maxBankCount,
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
    final p = value.split('/');
    if (p.length != 3) return null;
    final y = int.tryParse(_normalizeDigits(p[0]));
    final m = int.tryParse(_normalizeDigits(p[1]));
    final d = int.tryParse(_normalizeDigits(p[2]));
    if (y == null || m == null || d == null) return null;
    try {
      return Jalali(y, m, d).toDateTime();
    } catch (_) {
      return null;
    }
  }
}

class _BankCount {
  const _BankCount({required this.name, required this.count});
  final String name;
  final int count;
}

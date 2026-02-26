import 'package:flutter/cupertino.dart';

import '../models/finance_items.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'check_details_screen.dart';
import 'installment_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.installments,
    required this.checks,
  });

  final List<InstallmentItem> installments;
  final List<CheckItem> checks;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _query.trim();
    final installmentResults = _filterInstallments(normalizedQuery);
    final checkResults = _filterChecks(normalizedQuery);
    final hasResults = installmentResults.isNotEmpty || checkResults.isNotEmpty;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'جستجو',
          style: TextStyle(
            color: AppColors.titleText(context),
            fontFamily: 'Vazirmatn',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _SearchInput(
              controller: _controller,
              onChanged: (value) => setState(() => _query = value),
              onClear: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
            const SizedBox(height: AppSpacing.md),
            if (normalizedQuery.isEmpty)
              _hintCard(context)
            else if (!hasResults)
              _emptyState(context)
            else ...[
              if (installmentResults.isNotEmpty) ...[
                _sectionTitle(context, 'نتایج اقساط'),
                const SizedBox(height: AppSpacing.xs),
                ...installmentResults.map(
                  (item) => _installmentTile(context, item),
                ),
              ],
              if (checkResults.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _sectionTitle(context, 'نتایج چک ها'),
                const SizedBox(height: AppSpacing.xs),
                ...checkResults.map((item) => _checkTile(context, item)),
              ],
            ],
          ],
        ),
      ),
    );
  }

  List<InstallmentItem> _filterInstallments(String query) {
    if (query.isEmpty) return const [];
    return widget.installments
        .where(
          (item) =>
              item.title.contains(query) ||
              item.remainingAmount.contains(query) ||
              item.nextPaymentDate.contains(query),
        )
        .toList();
  }

  List<CheckItem> _filterChecks(String query) {
    if (query.isEmpty) return const [];
    final normalized = query.toLowerCase();
    return widget.checks
        .where(
          (item) {
            final typeFa = item.checkType == 'received'
                ? '\u062f\u0631\u06cc\u0627\u0641\u062a\u06cc'
                : '\u067e\u0631\u062f\u0627\u062e\u062a\u06cc';
            final settledFa = item.isSettled
                ? (item.checkType == 'received'
                      ? '\u062f\u0631\u06cc\u0627\u0641\u062a \u0634\u062f\u0647'
                      : '\u067e\u0631\u062f\u0627\u062e\u062a \u0634\u062f\u0647')
                : '\u062a\u0633\u0648\u06cc\u0647 \u0646\u0634\u062f\u0647';
            final haystack = <String>[
              item.title,
              item.amount,
              item.dueDate,
              item.counterparty,
              item.checkType,
              typeFa,
              item.checkNumber,
              item.sayadiNumber,
              item.bankName,
              item.issueDate,
              item.note,
              settledFa,
            ].join(' ').toLowerCase();
            return haystack.contains(normalized);
          },
        )
        .toList();
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.titleText(context),
      ),
    );
  }

  Widget _installmentTile(BuildContext context, InstallmentItem item) {
    return _ResultCard(
      title: item.title,
      subtitle: 'مانده: ${item.remainingAmount} تومان',
      dateLabel: 'سررسید: ${item.nextPaymentDate}',
      accentColor: AppColors.primary,
      icon: CupertinoIcons.doc_text_fill,
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute<void>(
            builder: (_) => InstallmentDetailsScreen(
              installment: item,
            ),
          ),
        );
      },
    );
  }

  Widget _checkTile(BuildContext context, CheckItem item) {
    return _ResultCard(
      title: item.title,
      subtitle: 'مبلغ: ${item.amount} تومان',
      dateLabel: 'سررسید: ${item.dueDate}',
      accentColor: AppColors.checksAccent,
      icon: CupertinoIcons.doc_on_clipboard_fill,
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute<void>(
            builder: (_) => CheckDetailsScreen(item: item),
          ),
        );
      },
    );
  }

  Widget _hintCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.sectionBackground(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'عنوان، مبلغ یا تاریخ را وارد کن تا اقساط و چک های مرتبط نمایش داده شوند.',
        style: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 14,
          color: AppColors.bodyText(context),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.sectionBackground(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.search,
            size: 30,
            color: AppColors.secondaryText(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'موردی پیدا نشد',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontWeight: FontWeight.w700,
              color: AppColors.titleText(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.sectionBackground(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.search,
            color: AppColors.secondaryText(context),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              onChanged: onChanged,
              placeholder: 'جستجو در اقساط و چک ها...',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 15,
                color: AppColors.bodyText(context),
              ),
              placeholderStyle: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 14,
                color: AppColors.secondaryText(context),
              ),
              decoration: const BoxDecoration(
                color: CupertinoColors.transparent,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: Icon(
                CupertinoIcons.clear_circled_solid,
                color: AppColors.secondaryText(context),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.accentColor,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String dateLabel;
  final Color accentColor;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.sectionBackground(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider(context), width: 0.7),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontWeight: FontWeight.w700,
                      color: AppColors.titleText(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 13,
                      color: AppColors.bodyText(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateLabel,
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 12,
                      color: AppColors.secondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_back,
              color: AppColors.secondaryText(context),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../data/app_data.dart';
import '../models/finance_items.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AddInstallmentScreen extends StatefulWidget {
  const AddInstallmentScreen({super.key});

  @override
  State<AddInstallmentScreen> createState() => _AddInstallmentScreenState();
}

class _AddInstallmentScreenState extends State<AddInstallmentScreen> {
  final _titleController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _durationController = TextEditingController();
  final _annualInterestController = TextEditingController();
  final _monthlyAmountController = TextEditingController();
  final _otherLenderController = TextEditingController();
  final _annualFeeAmountController = TextEditingController();
  final _penaltyFeeAmountController = TextEditingController();
  final _penaltyFeePercentController = TextEditingController();
  final _noteController = TextEditingController();

  final _currencyFormatter = NumberFormat('#,###');
  Jalali _firstDueDate = Jalali.now();
  String _selectedLender = AppData.lenders.first;
  bool _hasAnnualFee = false;
  bool _hasPenaltyFee = false;
  String _penaltyInputType = 'amount';
  bool _notifyPush = true;
  bool _notifyCalendar = false;
  String? _titleError;
  String? _totalAmountError;
  String? _durationError;
  String? _annualInterestError;
  String? _monthlyAmountError;
  String? _lenderError;
  String? _penaltyError;
  bool _isMonthlyManuallyEdited = false;
  bool _isAutoUpdatingMonthly = false;

  @override
  void initState() {
    super.initState();
    _totalAmountController.addListener(_recalculateMonthlyAmount);
    _durationController.addListener(_recalculateMonthlyAmount);
    _annualInterestController.addListener(_recalculateMonthlyAmount);
  }

  @override
  void dispose() {
    _totalAmountController.removeListener(_recalculateMonthlyAmount);
    _durationController.removeListener(_recalculateMonthlyAmount);
    _annualInterestController.removeListener(_recalculateMonthlyAmount);
    _titleController.dispose();
    _totalAmountController.dispose();
    _durationController.dispose();
    _annualInterestController.dispose();
    _monthlyAmountController.dispose();
    _otherLenderController.dispose();
    _annualFeeAmountController.dispose();
    _penaltyFeeAmountController.dispose();
    _penaltyFeePercentController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          color: AppColors.primary,
        ),
        middle: Text(
          'افزودن قسط جدید',
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
            _section(
              context,
              title: 'مشخصات وام',
              children: [
                _textInput(
                  context,
                  label: 'عنوان وام',
                  controller: _titleController,
                  placeholder: 'مثلا وام خرید خودرو',
                  errorText: _titleError,
                ),
                _textInput(
                  context,
                  label: 'مبلغ کلی وام',
                  suffix: 'تومان',
                  controller: _totalAmountController,
                  keyboardType: TextInputType.number,
                  numberFormatting: true,
                  errorText: _totalAmountError,
                ),
                _textInput(
                  context,
                  label: 'مدت بازپرداخت',
                  suffix: 'ماه',
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  numberFormatting: true,
                  errorText: _durationError,
                ),
                _textInput(
                  context,
                  label: 'سود سالیانه',
                  suffix: 'درصد',
                  controller: _annualInterestController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText: _annualInterestError,
                ),
                _textInput(
                  context,
                  label: 'مبلغ هر قسط',
                  suffix: 'تومان',
                  controller: _monthlyAmountController,
                  keyboardType: TextInputType.number,
                  numberFormatting: true,
                  errorText: _monthlyAmountError,
                  onChanged: (_) {
                    if (_isAutoUpdatingMonthly) return;
                    _isMonthlyManuallyEdited = _monthlyAmountController.text
                        .trim()
                        .isNotEmpty;
                  },
                ),
                _datePickerRow(context),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _section(
              context,
              title: 'موسسه پرداخت‌کننده',
              children: [
                _lenderPicker(context),
                if (_selectedLender == AppData.lenders.last)
                  _textInput(
                    context,
                    label: 'نام موسسه',
                    controller: _otherLenderController,
                    placeholder: 'نام موسسه را وارد کنید',
                    errorText: _lenderError,
                  ),
                if (_selectedLender != AppData.lenders.last &&
                    _lenderError != null)
                  _errorText(context, _lenderError!),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _section(
              context,
              title: 'تنظیمات مالی',
              children: [
                _switchRow(
                  context,
                  title: 'آیا وام دارای کارمزد سالیانه می‌باشد؟',
                  value: _hasAnnualFee,
                  onChanged: (value) => setState(() {
                    _hasAnnualFee = value;
                    if (!_isMonthlyManuallyEdited) _recalculateMonthlyAmount();
                  }),
                  helperTap: _showAnnualFeeHelp,
                ),
                _switchRow(
                  context,
                  title: 'آیا دیرکرد ماهیانه محاسبه می‌شود؟',
                  value: _hasPenaltyFee,
                  onChanged: (value) => setState(() => _hasPenaltyFee = value),
                ),
                if (_hasPenaltyFee) _penaltyInputSection(context),
                _textInput(
                  context,
                  label: 'توضیحات تکمیلی (اختیاری)',
                  controller: _noteController,
                  placeholder: 'مثلا امکان تسویه زودتر از موعد دارد',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _section(
              context,
              title: 'نحوه اطلاع‌رسانی',
              children: [
                _switchRow(
                  context,
                  title:
                      '\u0646\u0648\u062a\u06cc\u0641\u06cc\u06a9\u06cc\u0634\u0646',
                  value: _notifyPush,
                  onChanged: (value) => setState(() => _notifyPush = value),
                ),
                _switchRow(
                  context,
                  title: '\u0631\u0648\u06cc\u062f\u0627\u062f',
                  value: _notifyCalendar,
                  onChanged: (value) => setState(() => _notifyCalendar = value),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            CupertinoButton.filled(
              onPressed: _onSavePressed,
              borderRadius: BorderRadius.circular(14),
              child: const Text(
                'ذخیره و بررسی نهایی',
                style: TextStyle(fontFamily: 'Vazirmatn'),
              ),
            ),
            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.sectionBackground(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.titleText(context),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }

  Widget _textInput(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? placeholder,
    String? suffix,
    String? errorText,
    bool numberFormatting = false,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              color: AppColors.secondaryText(context),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.background(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider(context), width: 0.8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    placeholder: placeholder,
                    onChanged: onChanged,
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 15,
                      color: AppColors.titleText(context),
                    ),
                    placeholderStyle: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontFamily: 'Vazirmatn',
                    ),
                    inputFormatters: numberFormatting
                        ? [_ThousandsSeparatorInputFormatter()]
                        : null,
                    decoration: const BoxDecoration(
                      color: CupertinoColors.transparent,
                    ),
                  ),
                ),
                if (suffix != null)
                  Text(
                    suffix,
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 12,
                      color: AppColors.secondaryText(context),
                    ),
                  ),
              ],
            ),
          ),
          if (errorText != null) _errorText(context, errorText),
        ],
      ),
    );
  }

  Widget _errorText(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, right: 2),
      child: Text(
        text,
        style: const TextStyle(
          color: CupertinoColors.systemRed,
          fontFamily: 'Vazirmatn',
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _datePickerRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: _pickJalaliDate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider(context), width: 0.8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تاریخ سررسید قسط اول',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        color: AppColors.secondaryText(context),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _jalaliToString(_firstDueDate),
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        color: AppColors.titleText(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(CupertinoIcons.calendar, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lenderPicker(BuildContext context) {
    return GestureDetector(
      onTap: _pickLender,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider(context), width: 0.8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedLender,
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 15,
                  color: AppColors.titleText(context),
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_down,
              color: AppColors.secondaryText(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchRow(
    BuildContext context, {
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    VoidCallback? helperTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 14,
                      color: AppColors.bodyText(context),
                    ),
                  ),
                ),
                if (helperTap != null)
                  GestureDetector(
                    onTap: helperTap,
                    child: Icon(
                      CupertinoIcons.question_circle,
                      size: 19,
                      color: AppColors.secondaryText(context),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _penaltyInputSection(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.background(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider(context), width: 0.8),
          ),
          child: Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: _penaltyInputType == 'amount'
                      ? AppColors.primary.withValues(alpha: 0.16)
                      : CupertinoColors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  onPressed: () => setState(() => _penaltyInputType = 'amount'),
                  child: Text(
                    'مبلغ',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      color: AppColors.titleText(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: _penaltyInputType == 'percent'
                      ? AppColors.primary.withValues(alpha: 0.16)
                      : CupertinoColors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  onPressed: () =>
                      setState(() => _penaltyInputType = 'percent'),
                  child: Text(
                    'درصد',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      color: AppColors.titleText(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_penaltyInputType == 'amount')
          _textInput(
            context,
            label: 'دیرکرد ماهیانه',
            suffix: 'تومان',
            controller: _penaltyFeeAmountController,
            keyboardType: TextInputType.number,
          )
        else
          _textInput(
            context,
            label: 'دیرکرد ماهیانه',
            suffix: 'درصد',
            controller: _penaltyFeePercentController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        if (_penaltyError != null) _errorText(context, _penaltyError!),
      ],
    );
  }

  Future<void> _pickJalaliDate() async {
    Jalali temp = _firstDueDate;
    final now = Jalali.now();
    final years = List<int>.generate(12, (i) => now.year - 1 + i);
    final monthNames = [
      'فروردین',
      'اردیبهشت',
      'خرداد',
      'تیر',
      'مرداد',
      'شهریور',
      'مهر',
      'آبان',
      'آذر',
      'دی',
      'بهمن',
      'اسفند',
    ];

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) {
        int y = years.indexOf(temp.year);
        int m = temp.month - 1;
        int d = temp.day - 1;

        y = y < 0 ? 0 : y;

        return StatefulBuilder(
          builder: (context, setInner) {
            final currentYear = years[y];
            final daysInMonth = Jalali(currentYear, m + 1, 1).monthLength;
            if (d >= daysInMonth) d = daysInMonth - 1;

            return Container(
              height: 330,
              color: AppColors.sectionBackground(context),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 54,
                    child: Row(
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(popupContext).pop(),
                          child: const Text('لغو'),
                        ),
                        const Spacer(),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              _firstDueDate = Jalali(currentYear, m + 1, d + 1);
                            });
                            Navigator.of(popupContext).pop();
                          },
                          child: const Text('انتخاب'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 36,
                            scrollController: FixedExtentScrollController(
                              initialItem: y,
                            ),
                            onSelectedItemChanged: (value) =>
                                setInner(() => y = value),
                            children: years
                                .map(
                                  (e) => Center(
                                    child: Text(
                                      '$e',
                                      style: TextStyle(
                                        color: AppColors.titleText(context),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 36,
                            scrollController: FixedExtentScrollController(
                              initialItem: m,
                            ),
                            onSelectedItemChanged: (value) =>
                                setInner(() => m = value),
                            children: monthNames
                                .map(
                                  (e) => Center(
                                    child: Text(
                                      e,
                                      style: TextStyle(
                                        color: AppColors.titleText(context),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 36,
                            scrollController: FixedExtentScrollController(
                              initialItem: d,
                            ),
                            onSelectedItemChanged: (value) =>
                                setInner(() => d = value),
                            children: List.generate(
                              daysInMonth,
                              (index) => Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: AppColors.titleText(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickLender() async {
    String selected = _selectedLender;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          color: AppColors.sectionBackground(context),
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: Row(
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('تایید'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 38,
                  scrollController: FixedExtentScrollController(
                    initialItem: AppData.lenders.indexOf(_selectedLender),
                  ),
                  onSelectedItemChanged: (index) =>
                      selected = AppData.lenders[index],
                  children: AppData.lenders
                      .map(
                        (lender) => Center(
                          child: Text(
                            lender,
                            style: TextStyle(
                              color: AppColors.titleText(context),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;
    setState(() => _selectedLender = selected);
  }

  void _showAnnualFeeHelp() {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('راهنما'),
        content: const Text(
          'بعضی از وام‌ها سود یا کارمزد را به‌صورت سالیانه و یک‌جا دریافت می‌کنند، نه ماهیانه در هر قسط.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('متوجه شدم'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _recalculateMonthlyAmount() {
    if (_isMonthlyManuallyEdited) return;
    final total = _toNumber(_totalAmountController.text);
    final months = _toNumber(_durationController.text);
    final annualRate = _toDouble(_annualInterestController.text);
    if (total <= 0 || months <= 0) return;

    final monthlyRate = annualRate / 100 / 12;
    double payment;
    if (_hasAnnualFee) {
      payment = total / months;
    } else if (monthlyRate > 0) {
      final powVal = _pow(1 + monthlyRate, months.toDouble());
      payment = total * (monthlyRate * powVal) / (powVal - 1);
    } else {
      payment = total / months;
    }
    final formatted = _currencyFormatter.format(payment.round());
    if (_monthlyAmountController.text == formatted) return;
    _isAutoUpdatingMonthly = true;
    _monthlyAmountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    _isAutoUpdatingMonthly = false;
  }

  void _onSavePressed() {
    final title = _titleController.text.trim();
    final totalAmount = _toNumber(_totalAmountController.text);
    final durationMonths = _toNumber(_durationController.text);
    final annualInterest = _toDouble(_annualInterestController.text);
    final monthlyAmount = _toNumber(_monthlyAmountController.text);
    final annualFeeAmount = _hasAnnualFee
        ? ((totalAmount * annualInterest) / 100).round()
        : 0;
    final penaltyFeeAmount = _toNumber(_penaltyFeeAmountController.text);
    final penaltyFeePercent = _toDouble(_penaltyFeePercentController.text);
    final lender = _selectedLender == AppData.lenders.last
        ? _otherLenderController.text.trim()
        : _selectedLender;
    final annualInterestRaw = _normalizeDigits(_annualInterestController.text);
    final note = _noteController.text.trim();

    setState(() {
      _titleError = title.isEmpty ? 'این فیلد الزامی است.' : null;
      _totalAmountError = totalAmount <= 0 ? 'مبلغ معتبر وارد کنید.' : null;
      _durationError = durationMonths <= 0 ? 'مدت معتبر وارد کنید.' : null;
      _annualInterestError = annualInterestRaw.trim().isEmpty
          ? 'این فیلد الزامی است.'
          : null;
      _monthlyAmountError = monthlyAmount <= 0 ? 'مبلغ معتبر وارد کنید.' : null;
      _lenderError = lender.isEmpty ? 'نام موسسه را وارد کنید.' : null;
      _penaltyError = null;
    });

    if (_titleError != null ||
        _totalAmountError != null ||
        _durationError != null ||
        _annualInterestError != null ||
        _monthlyAmountError != null ||
        _lenderError != null) {
      _showError('لطفا خطاهای فرم را اصلاح کنید.');
      return;
    }

    if (_hasPenaltyFee) {
      final isAmount = _penaltyInputType == 'amount';
      final amountInvalid = isAmount && penaltyFeeAmount <= 0;
      final percentInvalid = !isAmount && penaltyFeePercent <= 0;
      if (amountInvalid || percentInvalid) {
        setState(() {
          _penaltyError = 'فقط یکی از مقدارها را درست وارد کنید.';
        });
        _showError(
          'Ø¨Ø±Ø§ÛŒ Ø¬Ø±ÛŒÙ…Ù‡ Ø¯ÛŒØ±Ú©Ø±Ø¯ØŒ ÙÙ‚Ø· ÛŒÚ© Ù…Ù‚Ø¯Ø§Ø± Ù…Ø¹ØªØ¨Ø± ÙˆØ§Ø±Ø¯ Ú©Ù†ÛŒØ¯.',
        );
        return;
      }
    }
    setState(() => _penaltyError = null);

    final installment = InstallmentItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      totalAmount: totalAmount.toString(),
      durationMonths: durationMonths,
      annualInterestPercent: annualInterest,
      monthlyInstallmentAmount: monthlyAmount.toString(),
      remainingAmount: totalAmount.toString(),
      firstDueDate: _jalaliToString(_firstDueDate),
      nextPaymentDate: _jalaliToString(_firstDueDate),
      lenderName: lender,
      hasAnnualFee: _hasAnnualFee,
      annualFeeAmount: annualFeeAmount.toString(),
      hasPenaltyFee: _hasPenaltyFee,
      penaltyFeeType: _penaltyInputType,
      penaltyFeeAmount: penaltyFeeAmount.toString(),
      penaltyFeePercent: penaltyFeePercent.toString(),
      notifyPush: _notifyPush,
      notifyCalendar: _notifyCalendar,
      notifySms: false,
      note: note,
      paidInstallmentIndexes: const [],
      installmentReceiptPaths: const {},
      createdAtIso: DateTime.now().toIso8601String(),
    );

    _showConfirmationModal(installment);
  }

  Future<void> _showConfirmationModal(InstallmentItem installment) async {
    final schedule = _buildSchedule(installment);
    final monthly = _toNumber(installment.monthlyInstallmentAmount);
    final months = installment.durationMonths;
    final totalPayable = schedule.fold<num>(
      0,
      (sum, item) => sum + item.amount,
    );
    final totalAmount = _toNumber(installment.totalAmount);
    final penaltyText = installment.hasPenaltyFee
        ? (installment.penaltyFeeType == 'percent'
              ? '${installment.penaltyFeePercent}%'
              : '${_currencyFormatter.format(_toNumber(installment.penaltyFeeAmount))} تومان')
        : 'ندارد';

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return Container(
          height: 560,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.sectionBackground(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'پیش‌نمایش نهایی',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.titleText(context),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.divider(context),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        installment.title,
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          color: AppColors.titleText(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _infoChip(context, 'موسسه', installment.lenderName),
                          _infoChip(
                            context,
                            'مبلغ کل',
                            '${_currencyFormatter.format(totalAmount)} تومان',
                          ),
                          _infoChip(context, 'مدت', '$months ماه'),
                          _infoChip(
                            context,
                            'سود',
                            '${installment.annualInterestPercent}%',
                          ),
                          _infoChip(
                            context,
                            'قسط ماهانه',
                            '${_currencyFormatter.format(monthly)} تومان',
                          ),
                          _infoChip(
                            context,
                            'کارمزد سالانه',
                            installment.hasAnnualFee ? 'دارد' : 'ندارد',
                          ),
                          _infoChip(context, 'جریمه دیرکرد', penaltyText),
                          _infoChip(
                            context,
                            'سررسید اول',
                            installment.firstDueDate,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'جمع پرداختی تقریبی: ${_currencyFormatter.format(totalPayable)} تومان',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      itemCount: schedule.length,
                      itemBuilder: (context, index) {
                        final item = schedule[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.monthLabel,
                                  style: TextStyle(
                                    fontFamily: 'Vazirmatn',
                                    color: AppColors.titleText(context),
                                  ),
                                ),
                              ),
                              Text(
                                '${_currencyFormatter.format(item.amount)} تومان',
                                style: TextStyle(
                                  fontFamily: 'Vazirmatn',
                                  color: AppColors.titleText(context),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CupertinoButton.filled(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(this.context).pop(installment);
                  },
                  child: const Text(
                    'تایید نهایی و ذخیره',
                    style: TextStyle(fontFamily: 'Vazirmatn'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoChip(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.sectionBackground(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider(context), width: 0.7),
      ),
      child: Text(
        '$title: $value',
        style: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 12,
          color: AppColors.bodyText(context),
        ),
      ),
    );
  }

  List<_ScheduleItem> _buildSchedule(InstallmentItem installment) {
    final items = <_ScheduleItem>[];
    final monthlyAmount = _toNumber(installment.monthlyInstallmentAmount);
    final annualRate = installment.annualInterestPercent / 100;
    final start = _firstDueDate;
    var remainingPrincipal = _toNumber(installment.totalAmount).toDouble();

    for (var i = 0; i < installment.durationMonths; i++) {
      final due = start.addMonths(i);
      var amount = monthlyAmount;
      if (installment.hasAnnualFee && (i + 1) % 12 == 0) {
        final yearlyInterest = (remainingPrincipal * annualRate).round();
        amount += yearlyInterest;
      }
      remainingPrincipal = (remainingPrincipal - monthlyAmount).clamp(
        0,
        double.infinity,
      );
      items.add(
        _ScheduleItem(
          monthLabel: 'قسط ${i + 1} - ${_jalaliToString(due)}',
          amount: amount,
        ),
      );
    }
    return items;
  }

  int _toNumber(String input) {
    final sanitized = _normalizeDigits(input).replaceAll(',', '').trim();
    return int.tryParse(sanitized) ?? 0;
  }

  double _toDouble(String input) {
    final sanitized = _normalizeDigits(input).replaceAll(',', '').trim();
    return double.tryParse(sanitized) ?? 0;
  }

  double _pow(double base, double exponent) {
    var result = 1.0;
    for (var i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
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

  String _jalaliToString(Jalali date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y/$m/$d';
  }

  void _showError(String message) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('خطا'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('باشه'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

class _ScheduleItem {
  const _ScheduleItem({required this.monthLabel, required this.amount});
  final String monthLabel;
  final num amount;
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _format = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    var text = newValue.text;
    const fa = '۰۱۲۳۴۵۶۷۸۹';
    const ar = '٠١٢٣٤٥٦٧٨٩';
    for (var i = 0; i < 10; i++) {
      text = text.replaceAll(fa[i], '$i');
      text = text.replaceAll(ar[i], '$i');
    }
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final formatted = _format.format(int.parse(digitsOnly));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

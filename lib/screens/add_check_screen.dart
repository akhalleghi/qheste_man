import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../models/finance_items.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AddCheckScreen extends StatefulWidget {
  const AddCheckScreen({super.key});

  @override
  State<AddCheckScreen> createState() => _AddCheckScreenState();
}

class _AddCheckScreenState extends State<AddCheckScreen> {
  final _amountController = TextEditingController();
  final _counterpartyController = TextEditingController();
  final _titleController = TextEditingController();
  final _checkNumberController = TextEditingController();
  final _sayadiController = TextEditingController();
  final _bankController = TextEditingController();
  final _noteController = TextEditingController();
  final _picker = ImagePicker();

  Jalali _dueDate = Jalali.now();
  Jalali _issueDate = Jalali.now();
  String _checkType = 'received';
  String _imagePath = '';

  String? _amountError;
  String? _counterpartyError;

  @override
  void dispose() {
    _amountController.dispose();
    _counterpartyController.dispose();
    _titleController.dispose();
    _checkNumberController.dispose();
    _sayadiController.dispose();
    _bankController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(color: AppColors.primary),
        middle: Text(
          '\u0627\u0641\u0632\u0648\u062f\u0646 \u0686\u06a9 \u062c\u062f\u06cc\u062f',
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
              title: '\u0627\u0637\u0644\u0627\u0639\u0627\u062a \u0636\u0631\u0648\u0631\u06cc',
              children: [
                _textInput(
                  context,
                  label: '\u0645\u0628\u0644\u063a \u0686\u06a9',
                  suffix: '\u062a\u0648\u0645\u0627\u0646',
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  numberFormatting: true,
                  errorText: _amountError,
                ),
                _dateRow(
                  context,
                  title: '\u062a\u0627\u0631\u06cc\u062e \u0633\u0631\u0631\u0633\u06cc\u062f',
                  value: _dueDate,
                  onTap: () => _pickDate(isDueDate: true),
                ),
                _textInput(
                  context,
                  label: '\u0637\u0631\u0641 \u062d\u0633\u0627\u0628',
                  controller: _counterpartyController,
                  placeholder:
                      '\u0646\u0627\u0645 \u0635\u0627\u062f\u0631\u06a9\u0646\u0646\u062f\u0647 \u06cc\u0627 \u062f\u0631\u06cc\u0627\u0641\u062a\u200c\u06a9\u0646\u0646\u062f\u0647',
                  errorText: _counterpartyError,
                ),
                _checkTypeSegment(context),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _section(
              context,
              title: '\u0627\u0637\u0644\u0627\u0639\u0627\u062a \u0627\u062e\u062a\u06cc\u0627\u0631\u06cc',
              children: [
                _textInput(
                  context,
                  label: '\u0639\u0646\u0648\u0627\u0646 \u0686\u06a9 (\u0627\u062e\u062a\u06cc\u0627\u0631\u06cc)',
                  controller: _titleController,
                  placeholder: '\u0645\u062b\u0644\u0627 \u0686\u06a9 \u0627\u062c\u0627\u0631\u0647',
                ),
                _textInput(
                  context,
                  label: '\u0634\u0645\u0627\u0631\u0647 \u0686\u06a9',
                  controller: _checkNumberController,
                  keyboardType: TextInputType.number,
                  numberFormatting: true,
                ),
                _textInput(
                  context,
                  label: '\u0634\u0645\u0627\u0631\u0647 \u0635\u06cc\u0627\u062f\u06cc',
                  controller: _sayadiController,
                  keyboardType: TextInputType.number,
                ),
                _textInput(
                  context,
                  label: '\u0646\u0627\u0645 \u0628\u0627\u0646\u06a9',
                  controller: _bankController,
                  placeholder:
                      '\u0645\u062b\u0644\u0627 \u0628\u0627\u0646\u06a9 \u0645\u0644\u06cc\u060c \u0645\u0644\u062a\u060c \u067e\u0627\u0633\u0627\u0631\u06af\u0627\u062f',
                ),
                _dateRow(
                  context,
                  title: '\u062a\u0627\u0631\u06cc\u062e \u0635\u062f\u0648\u0631',
                  value: _issueDate,
                  onTap: () => _pickDate(isDueDate: false),
                ),
                _textInput(
                  context,
                  label: '\u062a\u0648\u0636\u06cc\u062d\u0627\u062a',
                  controller: _noteController,
                  placeholder:
                      '\u0645\u062b\u0644\u0627 \u0628\u0627\u0628\u062a \u0627\u062c\u0627\u0631\u0647 \u062e\u0631\u062f\u0627\u062f',
                ),
                _imagePickerSection(context),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            CupertinoButton.filled(
              borderRadius: BorderRadius.circular(14),
              onPressed: _submit,
              child: const Text(
                '\u0630\u062e\u06cc\u0631\u0647 \u0686\u06a9',
                style: TextStyle(fontFamily: 'Vazirmatn'),
              ),
            ),
            const SizedBox(height: 70),
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
    String? placeholder,
    String? suffix,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    bool numberFormatting = false,
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
                    placeholder: placeholder,
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      color: AppColors.titleText(context),
                    ),
                    placeholderStyle: TextStyle(
                      fontFamily: 'Vazirmatn',
                      color: AppColors.secondaryText(context),
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
                      color: AppColors.secondaryText(context),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                errorText,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  color: CupertinoColors.systemRed,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _checkTypeSegment(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\u0646\u0648\u0639 \u0686\u06a9',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              color: AppColors.secondaryText(context),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          CupertinoSlidingSegmentedControl<String>(
            groupValue: _checkType,
            thumbColor: AppColors.primary.withValues(alpha: 0.22),
            children: const {
              'received': Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  '\u062f\u0631\u06cc\u0627\u0641\u062a\u06cc',
                  style: TextStyle(fontFamily: 'Vazirmatn'),
                ),
              ),
              'paid': Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  '\u067e\u0631\u062f\u0627\u062e\u062a\u06cc',
                  style: TextStyle(fontFamily: 'Vazirmatn'),
                ),
              ),
            },
            onValueChanged: (v) {
              if (v == null) return;
              setState(() => _checkType = v);
            },
          ),
        ],
      ),
    );
  }

  Widget _dateRow(
    BuildContext context, {
    required String title,
    required Jalali value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
                    title,
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      color: AppColors.secondaryText(context),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _jalaliToString(value),
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      color: AppColors.titleText(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.calendar, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _imagePickerSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider(context), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\u062a\u0635\u0648\u06cc\u0631 \u0686\u06a9',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              color: AppColors.secondaryText(context),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          if (_imagePath.isNotEmpty)
            GestureDetector(
              onTap: () => _showImagePreview(_imagePath),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Image.file(
                      File(_imagePath),
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: GestureDetector(
                        onTap: () => setState(() => _imagePath = ''),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: CupertinoColors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.delete_solid,
                            size: 14,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                  onPressed: () => _pickImage(_PickSource.gallery),
                  child: const Text(
                    '\u06af\u0627\u0644\u0631\u06cc',
                    style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                  onPressed: () => _pickImage(_PickSource.camera),
                  child: const Text(
                    '\u062f\u0648\u0631\u0628\u06cc\u0646',
                    style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                  onPressed: () => _pickImage(_PickSource.file),
                  child: const Text(
                    '\u0641\u0627\u06cc\u0644',
                    style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(_PickSource source) async {
    try {
      String? path;
      if (source == _PickSource.gallery) {
        path = (await _picker.pickImage(source: ImageSource.gallery))?.path;
      } else if (source == _PickSource.camera) {
        path = (await _picker.pickImage(source: ImageSource.camera))?.path;
      } else {
        final file = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
        );
        path = file?.files.single.path;
      }
      if (!mounted || path == null) return;
      final selectedPath = path;
      setState(() => _imagePath = selectedPath);
    } catch (_) {}
  }

  Future<void> _pickDate({required bool isDueDate}) async {
    final init = isDueDate ? _dueDate : _issueDate;
    var y = init.year;
    var m = init.month;
    var d = init.day;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setInner) {
            final maxDay = Jalali(y, m).monthLength;
            if (d > maxDay) d = maxDay;
            return Container(
              height: 350,
              color: AppColors.sectionBackground(context),
              child: Column(
                children: [
                  SizedBox(
                    height: 52,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            '\u0627\u0646\u0635\u0631\u0627\u0641',
                            style: TextStyle(fontFamily: 'Vazirmatn'),
                          ),
                        ),
                        CupertinoButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            '\u062a\u0627\u06cc\u06cc\u062f',
                            style: TextStyle(fontFamily: 'Vazirmatn'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '\u0631\u0648\u0632',
                                style: TextStyle(
                                  fontFamily: 'Vazirmatn',
                                  fontSize: 12,
                                  color: AppColors.secondaryText(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: CupertinoPicker(
                                  itemExtent: 34,
                                  scrollController: FixedExtentScrollController(
                                    initialItem: d - 1,
                                  ),
                                  onSelectedItemChanged: (i) =>
                                      setInner(() => d = i + 1),
                                  children: List.generate(
                                    maxDay,
                                    (i) => Center(
                                      child: Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          fontFamily: 'Vazirmatn',
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
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '\u0645\u0627\u0647',
                                style: TextStyle(
                                  fontFamily: 'Vazirmatn',
                                  fontSize: 12,
                                  color: AppColors.secondaryText(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: CupertinoPicker(
                                  itemExtent: 34,
                                  scrollController: FixedExtentScrollController(
                                    initialItem: m - 1,
                                  ),
                                  onSelectedItemChanged: (i) =>
                                      setInner(() => m = i + 1),
                                  children: List.generate(
                                    12,
                                    (i) => Center(
                                      child: Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          fontFamily: 'Vazirmatn',
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
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '\u0633\u0627\u0644',
                                style: TextStyle(
                                  fontFamily: 'Vazirmatn',
                                  fontSize: 12,
                                  color: AppColors.secondaryText(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: CupertinoPicker(
                                  itemExtent: 34,
                                  scrollController: FixedExtentScrollController(
                                    initialItem: (y - 1390).clamp(0, 79),
                                  ),
                                  onSelectedItemChanged: (i) =>
                                      setInner(() => y = 1390 + i),
                                  children: List.generate(
                                    80,
                                    (i) => Center(
                                      child: Text(
                                        '${1390 + i}',
                                        style: TextStyle(
                                          fontFamily: 'Vazirmatn',
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
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (!mounted) return;
    setState(() {
      if (isDueDate) {
        _dueDate = Jalali(y, m, d);
      } else {
        _issueDate = Jalali(y, m, d);
      }
    });
  }

  void _submit() {
    final amount = _toNumber(_amountController.text);
    final counterparty = _counterpartyController.text.trim();
    setState(() {
      _amountError = amount <= 0
          ? '\u0645\u0628\u0644\u063a \u0645\u0639\u062a\u0628\u0631 \u0648\u0627\u0631\u062f \u06a9\u0646\u06cc\u062f.'
          : null;
      _counterpartyError = counterparty.isEmpty
          ? '\u0627\u06cc\u0646 \u0641\u06cc\u0644\u062f \u0627\u0644\u0632\u0627\u0645\u06cc \u0627\u0633\u062a.'
          : null;
    });
    if (_amountError != null || _counterpartyError != null) {
      _showRequiredFieldsMessage();
      return;
    }

    final check = CheckItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim().isEmpty
          ? '\u0686\u06a9 ${_checkType == 'received' ? '\u062f\u0631\u06cc\u0627\u0641\u062a\u06cc' : '\u067e\u0631\u062f\u0627\u062e\u062a\u06cc'}'
          : _titleController.text.trim(),
      amount: amount.toString(),
      dueDate: _jalaliToString(_dueDate),
      counterparty: counterparty,
      checkType: _checkType,
      checkNumber: _checkNumberController.text.trim(),
      sayadiNumber: _sayadiController.text.trim(),
      bankName: _bankController.text.trim(),
      issueDate: _jalaliToString(_issueDate),
      note: _noteController.text.trim(),
      imagePath: _imagePath,
      isSettled: false,
      createdAtIso: DateTime.now().toIso8601String(),
    );
    Navigator.of(context).pop(check);
  }

  void _showImagePreview(String path) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        color: CupertinoColors.black.withValues(alpha: 0.92),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Image.file(File(path)),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: CupertinoButton(
                  padding: const EdgeInsets.all(8),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(
                    CupertinoIcons.clear_circled_solid,
                    color: CupertinoColors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRequiredFieldsMessage() {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          '\u062a\u06a9\u0645\u06cc\u0644 \u0641\u06cc\u0644\u062f\u0647\u0627\u06cc \u0627\u0644\u0632\u0627\u0645\u06cc',
          style: TextStyle(fontFamily: 'Vazirmatn'),
        ),
        content: const Text(
          '\u0641\u06cc\u0644\u062f\u0647\u0627\u06cc \u0627\u062c\u0628\u0627\u0631\u06cc \u0631\u0627 \u0628\u0627 \u062f\u0642\u062a \u0648\u0627\u0631\u062f \u06a9\u0646\u06cc\u062f. \u0644\u0637\u0641\u0627 \u0645\u0628\u0644\u063a \u0686\u06a9 \u0648 \u0637\u0631\u0641 \u062d\u0633\u0627\u0628 \u0631\u0627 \u0628\u0631\u0631\u0633\u06cc \u06a9\u0646\u06cc\u062f.',
          style: TextStyle(fontFamily: 'Vazirmatn'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '\u0628\u0627\u0634\u0647',
              style: TextStyle(fontFamily: 'Vazirmatn'),
            ),
          ),
        ],
      ),
    );
  }

  int _toNumber(String input) {
    return int.tryParse(_normalizeDigits(input).replaceAll(',', '')) ?? 0;
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
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');
    final formatted = _format.format(int.parse(digitsOnly));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

enum _PickSource { gallery, camera, file }

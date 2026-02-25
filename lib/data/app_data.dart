import '../models/finance_items.dart';

class AppData {
  static const installments = [
    InstallmentItem(
      title: 'وام خودرو',
      remainingAmount: '۱۲,۰۰۰,۰۰۰',
      nextPaymentDate: '۱۴۰۴/۱۲/۱۵',
    ),
    InstallmentItem(
      title: 'قسط لپ‌تاپ',
      remainingAmount: '۸,۵۰۰,۰۰۰',
      nextPaymentDate: '۱۴۰۴/۱۲/۲۲',
    ),
    InstallmentItem(
      title: 'وام شخصی',
      remainingAmount: '۲۴,۰۰۰,۰۰۰',
      nextPaymentDate: '۱۴۰۵/۰۱/۰۵',
    ),
  ];

  static const checks = [
    CheckItem(
      title: 'چک اجاره دفتر',
      amount: '۹,۵۰۰,۰۰۰',
      dueDate: '۱۴۰۴/۱۲/۱۰',
    ),
    CheckItem(
      title: 'چک تامین تجهیزات',
      amount: '۶,۲۰۰,۰۰۰',
      dueDate: '۱۴۰۴/۱۲/۲۰',
    ),
    CheckItem(
      title: 'چک خرید اقساطی',
      amount: '۱۴,۰۰۰,۰۰۰',
      dueDate: '۱۴۰۵/۰۱/۰۸',
    ),
  ];
}

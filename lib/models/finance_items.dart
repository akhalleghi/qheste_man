class InstallmentItem {
  const InstallmentItem({
    required this.title,
    required this.remainingAmount,
    required this.nextPaymentDate,
  });

  final String title;
  final String remainingAmount;
  final String nextPaymentDate;
}

class CheckItem {
  const CheckItem({
    required this.title,
    required this.amount,
    required this.dueDate,
  });

  final String title;
  final String amount;
  final String dueDate;
}

class InstallmentItem {
  const InstallmentItem({
    required this.id,
    required this.title,
    required this.totalAmount,
    required this.durationMonths,
    required this.annualInterestPercent,
    required this.monthlyInstallmentAmount,
    required this.remainingAmount,
    required this.firstDueDate,
    required this.nextPaymentDate,
    required this.lenderName,
    required this.hasAnnualFee,
    required this.annualFeeAmount,
    required this.hasPenaltyFee,
    required this.penaltyFeeType,
    required this.penaltyFeeAmount,
    required this.penaltyFeePercent,
    required this.notifyPush,
    required this.notifyCalendar,
    required this.notifySms,
    required this.note,
    required this.paidInstallmentIndexes,
    required this.installmentReceiptPaths,
    required this.createdAtIso,
  });

  final String id;
  final String title;
  final String totalAmount;
  final int durationMonths;
  final double annualInterestPercent;
  final String monthlyInstallmentAmount;
  final String remainingAmount;
  final String firstDueDate;
  final String nextPaymentDate;
  final String lenderName;
  final bool hasAnnualFee;
  final String annualFeeAmount;
  final bool hasPenaltyFee;
  final String penaltyFeeType;
  final String penaltyFeeAmount;
  final String penaltyFeePercent;
  final bool notifyPush;
  final bool notifyCalendar;
  final bool notifySms;
  final String note;
  final List<int> paidInstallmentIndexes;
  final Map<String, String> installmentReceiptPaths;
  final String createdAtIso;

  InstallmentItem copyWith({
    String? remainingAmount,
    String? nextPaymentDate,
    List<int>? paidInstallmentIndexes,
    Map<String, String>? installmentReceiptPaths,
  }) {
    return InstallmentItem(
      id: id,
      title: title,
      totalAmount: totalAmount,
      durationMonths: durationMonths,
      annualInterestPercent: annualInterestPercent,
      monthlyInstallmentAmount: monthlyInstallmentAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      firstDueDate: firstDueDate,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      lenderName: lenderName,
      hasAnnualFee: hasAnnualFee,
      annualFeeAmount: annualFeeAmount,
      hasPenaltyFee: hasPenaltyFee,
      penaltyFeeType: penaltyFeeType,
      penaltyFeeAmount: penaltyFeeAmount,
      penaltyFeePercent: penaltyFeePercent,
      notifyPush: notifyPush,
      notifyCalendar: notifyCalendar,
      notifySms: notifySms,
      note: note,
      paidInstallmentIndexes:
          paidInstallmentIndexes ?? this.paidInstallmentIndexes,
      installmentReceiptPaths:
          installmentReceiptPaths ?? this.installmentReceiptPaths,
      createdAtIso: createdAtIso,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'totalAmount': totalAmount,
      'durationMonths': durationMonths,
      'annualInterestPercent': annualInterestPercent,
      'monthlyInstallmentAmount': monthlyInstallmentAmount,
      'remainingAmount': remainingAmount,
      'firstDueDate': firstDueDate,
      'nextPaymentDate': nextPaymentDate,
      'lenderName': lenderName,
      'hasAnnualFee': hasAnnualFee,
      'annualFeeAmount': annualFeeAmount,
      'hasPenaltyFee': hasPenaltyFee,
      'penaltyFeeType': penaltyFeeType,
      'penaltyFeeAmount': penaltyFeeAmount,
      'penaltyFeePercent': penaltyFeePercent,
      'notifyPush': notifyPush,
      'notifyCalendar': notifyCalendar,
      'notifySms': notifySms,
      'note': note,
      'paidInstallmentIndexes': paidInstallmentIndexes,
      'installmentReceiptPaths': installmentReceiptPaths,
      'createdAtIso': createdAtIso,
    };
  }

  factory InstallmentItem.fromJson(Map<String, dynamic> json) {
    return InstallmentItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      totalAmount: json['totalAmount'] as String? ?? '0',
      durationMonths: json['durationMonths'] as int? ?? 0,
      annualInterestPercent:
          (json['annualInterestPercent'] as num?)?.toDouble() ?? 0,
      monthlyInstallmentAmount:
          json['monthlyInstallmentAmount'] as String? ?? '0',
      remainingAmount: json['remainingAmount'] as String? ?? '0',
      firstDueDate: json['firstDueDate'] as String? ?? '',
      nextPaymentDate: json['nextPaymentDate'] as String? ?? '',
      lenderName: json['lenderName'] as String? ?? '',
      hasAnnualFee: json['hasAnnualFee'] as bool? ?? false,
      annualFeeAmount: json['annualFeeAmount'] as String? ?? '0',
      hasPenaltyFee: json['hasPenaltyFee'] as bool? ?? false,
      penaltyFeeType: json['penaltyFeeType'] as String? ?? 'amount',
      penaltyFeeAmount: json['penaltyFeeAmount'] as String? ?? '0',
      penaltyFeePercent: json['penaltyFeePercent'] as String? ?? '0',
      notifyPush: json['notifyPush'] as bool? ?? true,
      notifyCalendar: json['notifyCalendar'] as bool? ?? false,
      notifySms: json['notifySms'] as bool? ?? false,
      note: json['note'] as String? ?? '',
      paidInstallmentIndexes: ((json['paidInstallmentIndexes'] as List?) ?? [])
          .map((e) => e as int)
          .toList(),
      installmentReceiptPaths:
          ((json['installmentReceiptPaths'] as Map?) ?? {}).map(
            (key, value) => MapEntry('$key', '$value'),
          ),
      createdAtIso: json['createdAtIso'] as String? ?? '',
    );
  }
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

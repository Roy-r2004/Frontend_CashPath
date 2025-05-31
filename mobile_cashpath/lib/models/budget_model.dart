class Budget {
  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  final String period;
  final DateTime startDate;
  final DateTime? endDate;
  final double spentAmount;
  final String status;

  Budget({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
    this.endDate,
    required this.spentAmount,
    required this.status,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      amount: (json['amount'] as num).toDouble(),
      period: json['period'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      spentAmount: (json['spent_amount'] as num).toDouble(),
      status: json['status'],
    );
  }
}

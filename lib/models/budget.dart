class Budget {
  final String id;
  final String category;
  final double amount;
  final String period; // 'monthly', 'weekly', 'yearly'
  final DateTime startDate;
  final DateTime? endDate;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.period,
    required this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'period': period,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      category: map['category'],
      amount: map['amount'],
      period: map['period'],
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
    );
  }
}

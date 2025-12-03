enum TransactionType {
  income,
  expense,
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? notes;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.index,
      'category': category,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      type: TransactionType.values[map['type']],
      category: map['category'],
      date: DateTime.parse(map['date']),
      notes: map['notes'],
    );
  }
}

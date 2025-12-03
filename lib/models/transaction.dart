enum TransactionType {
  income,
  expense,
  investment,
}

class Transaction {
  final String id;
  final TransactionType type;
  final String mainCategory;
  final String subCategory;
  final double amount;
  final String date; // YYYY-MM-DD format
  final String time; // HH:MM AM/PM format
  final String? notes;

  Transaction({
    required this.id,
    required this.type,
    required this.mainCategory,
    required this.subCategory,
    required this.amount,
    required this.date,
    required this.time,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'mainCategory': mainCategory,
      'subCategory': subCategory,
      'amount': amount,
      'date': date,
      'time': time,
      'notes': notes,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: TransactionType.values[map['type']],
      mainCategory: map['mainCategory'],
      subCategory: map['subCategory'],
      amount: map['amount'],
      date: map['date'],
      time: map['time'],
      notes: map['notes'],
    );
  }

  Transaction copyWith({
    String? id,
    TransactionType? type,
    String? mainCategory,
    String? subCategory,
    double? amount,
    String? date,
    String? time,
    String? notes,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      mainCategory: mainCategory ?? this.mainCategory,
      subCategory: subCategory ?? this.subCategory,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      time: time ?? this.time,
      notes: notes ?? this.notes,
    );
  }
}

class TransactionRecord {
  final String id;
  final String itemId;
  final String itemName;
  final double amount;
  final DateTime date;
  final String type; // 'contribution' or 'payment'

  TransactionRecord({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.amount,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    return TransactionRecord(
      id: json['id'],
      itemId: json['itemId'],
      itemName: json['itemName'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      type: json['type'],
    );
  }
}

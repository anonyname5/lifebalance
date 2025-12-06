/// Expense model
class Expense {
  final int? id;
  final double amount;
  final String category;
  final String? description;
  final String date;
  final String time;
  final String? receiptPhotoPath;
  final String? createdAt;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    this.description,
    required this.date,
    required this.time,
    this.receiptPhotoPath,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date,
      'time': time,
      'receipt_photo_path': receiptPhotoPath,
      'created_at': createdAt,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      description: map['description'] as String?,
      date: map['date'] as String,
      time: map['time'] as String,
      receiptPhotoPath: map['receipt_photo_path'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  Expense copyWith({
    int? id,
    double? amount,
    String? category,
    String? description,
    String? date,
    String? time,
    String? receiptPhotoPath,
    String? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      receiptPhotoPath: receiptPhotoPath ?? this.receiptPhotoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

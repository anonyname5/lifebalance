/// Recurring expense model
class RecurringExpense {
  final int? id;
  final String name;
  final double amount;
  final String category;
  final String? frequency; // monthly, weekly
  final int? dayOfMonth; // For monthly: 1-31
  final int isActive; // 1 for active, 0 for inactive

  RecurringExpense({
    this.id,
    required this.name,
    required this.amount,
    required this.category,
    this.frequency,
    this.dayOfMonth,
    this.isActive = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'frequency': frequency,
      'day_of_month': dayOfMonth,
      'is_active': isActive,
    };
  }

  factory RecurringExpense.fromMap(Map<String, dynamic> map) {
    return RecurringExpense(
      id: map['id'] as int?,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      frequency: map['frequency'] as String?,
      dayOfMonth: map['day_of_month'] as int?,
      isActive: map['is_active'] as int? ?? 1,
    );
  }

  RecurringExpense copyWith({
    int? id,
    String? name,
    double? amount,
    String? category,
    String? frequency,
    int? dayOfMonth,
    int? isActive,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Check if expense should be logged today
  bool shouldLogToday() {
    if (isActive != 1) return false;
    if (frequency == null) return false;

    final today = DateTime.now();

    if (frequency == 'weekly') {
      // For weekly, we could check if it's the right day of week
      // For simplicity, we'll let user manually trigger or schedule
      return false;
    } else if (frequency == 'monthly') {
      if (dayOfMonth == null) return false;
      return today.day == dayOfMonth;
    }

    return false;
  }
}

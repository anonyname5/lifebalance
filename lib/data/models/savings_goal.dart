/// Savings goal model
class SavingsGoal {
  final int? id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String? targetDate;
  final int isCompleted;
  final String? createdAt;

  SavingsGoal({
    this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.targetDate,
    this.isCompleted = 0,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate,
      'is_completed': isCompleted,
      'created_at': createdAt,
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'] as int?,
      name: map['name'] as String,
      targetAmount: (map['target_amount'] as num).toDouble(),
      currentAmount: (map['current_amount'] as num?)?.toDouble() ?? 0.0,
      targetDate: map['target_date'] as String?,
      isCompleted: map['is_completed'] as int? ?? 0,
      createdAt: map['created_at'] as String?,
    );
  }

  SavingsGoal copyWith({
    int? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    String? targetDate,
    int? isCompleted,
    String? createdAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get progress percentage (0.0 to 1.0)
  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0.0;

  /// Get remaining amount
  double get remaining => targetAmount - currentAmount;

  /// Check if goal is completed
  bool get isGoalCompleted => isCompleted == 1 || currentAmount >= targetAmount;
}

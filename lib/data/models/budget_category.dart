/// Budget category model
class BudgetCategory {
  final int? id;
  final String name;
  final double monthlyLimit;
  final String? color; // hex color code
  final String? icon; // icon name
  final int isActive; // 1 for active, 0 for inactive

  BudgetCategory({
    this.id,
    required this.name,
    required this.monthlyLimit,
    this.color,
    this.icon,
    this.isActive = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'monthly_limit': monthlyLimit,
      'color': color,
      'icon': icon,
      'is_active': isActive,
    };
  }

  factory BudgetCategory.fromMap(Map<String, dynamic> map) {
    return BudgetCategory(
      id: map['id'] as int?,
      name: map['name'] as String,
      monthlyLimit: (map['monthly_limit'] as num).toDouble(),
      color: map['color'] as String?,
      icon: map['icon'] as String?,
      isActive: map['is_active'] as int? ?? 1,
    );
  }

  BudgetCategory copyWith({
    int? id,
    String? name,
    double? monthlyLimit,
    String? color,
    String? icon,
    int? isActive,
  }) {
    return BudgetCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
    );
  }
}

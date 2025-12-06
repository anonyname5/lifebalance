/// Meal log model
class MealLog {
  final int? id;
  final String mealType; // breakfast, lunch, dinner, snack
  final String date;
  final String time;
  final String? notes;
  final String? createdAt;

  MealLog({
    this.id,
    required this.mealType,
    required this.date,
    required this.time,
    this.notes,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meal_type': mealType,
      'date': date,
      'time': time,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory MealLog.fromMap(Map<String, dynamic> map) {
    return MealLog(
      id: map['id'] as int?,
      mealType: map['meal_type'] as String,
      date: map['date'] as String,
      time: map['time'] as String,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  MealLog copyWith({
    int? id,
    String? mealType,
    String? date,
    String? time,
    String? notes,
    String? createdAt,
  }) {
    return MealLog(
      id: id ?? this.id,
      mealType: mealType ?? this.mealType,
      date: date ?? this.date,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

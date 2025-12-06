/// Model for notification schedule
class NotificationSchedule {
  final int hour;
  final int minute;
  final String? message;
  final String? mealType;

  NotificationSchedule({
    required this.hour,
    required this.minute,
    this.message,
    this.mealType,
  });

  Map<String, dynamic> toMap() {
    return {
      'hour': hour,
      'minute': minute,
      'message': message,
      'mealType': mealType,
    };
  }

  factory NotificationSchedule.fromMap(Map<String, dynamic> map) {
    return NotificationSchedule(
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      message: map['message'] as String?,
      mealType: map['mealType'] as String?,
    );
  }

  NotificationSchedule copyWith({
    int? hour,
    int? minute,
    String? message,
    String? mealType,
  }) {
    return NotificationSchedule(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      message: message ?? this.message,
      mealType: mealType ?? this.mealType,
    );
  }
}

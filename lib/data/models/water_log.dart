/// Water log model
class WaterLog {
  final int? id;
  final String date;
  final int glasses;
  final String timestamp;
  final String? createdAt;

  WaterLog({
    this.id,
    required this.date,
    required this.glasses,
    required this.timestamp,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'glasses': glasses,
      'timestamp': timestamp,
      'created_at': createdAt,
    };
  }

  factory WaterLog.fromMap(Map<String, dynamic> map) {
    return WaterLog(
      id: map['id'] as int?,
      date: map['date'] as String,
      glasses: map['glasses'] as int,
      timestamp: map['timestamp'] as String,
      createdAt: map['created_at'] as String?,
    );
  }

  WaterLog copyWith({
    int? id,
    String? date,
    int? glasses,
    String? timestamp,
    String? createdAt,
  }) {
    return WaterLog(
      id: id ?? this.id,
      date: date ?? this.date,
      glasses: glasses ?? this.glasses,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

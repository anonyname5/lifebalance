/// User profile model
class UserProfile {
  final int? id;
  final String? name;
  final double? monthlyIncome;
  final int waterGoal;
  final String? profilePicturePath;
  final String? createdAt;
  final String? updatedAt;

  UserProfile({
    this.id,
    this.name,
    this.monthlyIncome,
    this.waterGoal = 8,
    this.profilePicturePath,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'monthly_income': monthlyIncome,
      'water_goal': waterGoal,
      'profile_picture_path': profilePicturePath,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int?,
      name: map['name'] as String?,
      monthlyIncome: map['monthly_income'] != null
          ? (map['monthly_income'] as num).toDouble()
          : null,
      waterGoal: map['water_goal'] as int? ?? 8,
      profilePicturePath: map['profile_picture_path'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  UserProfile copyWith({
    int? id,
    String? name,
    double? monthlyIncome,
    int? waterGoal,
    String? profilePicturePath,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      waterGoal: waterGoal ?? this.waterGoal,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

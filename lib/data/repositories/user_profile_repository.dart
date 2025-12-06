import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/tables.dart';
import '../models/user_profile.dart';
import '../../core/utils/date_helper.dart';

/// Repository for user profile operations
class UserProfileRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Get user profile (there should only be one)
  Future<UserProfile?> getUserProfile() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.userProfile,
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return UserProfile.fromMap(maps.first);
  }

  /// Create or update user profile
  Future<int> saveUserProfile(UserProfile profile) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    final existing = await getUserProfile();

    if (existing == null) {
      // Create new profile
      return await db.insert(
        Tables.userProfile,
        profile.copyWith(
          id: 1,
          createdAt: now,
          updatedAt: now,
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      // Update existing profile
      return await db.update(
        Tables.userProfile,
        profile.copyWith(
          id: existing.id,
          updatedAt: now,
        ).toMap(),
        where: '${Tables.userId} = ?',
        whereArgs: [existing.id],
      );
    }
  }

  /// Update user name
  Future<int> updateUserName(String name) async {
    final profile = await getUserProfile();
    if (profile == null) {
      return await saveUserProfile(UserProfile(name: name));
    }
    return await saveUserProfile(profile.copyWith(name: name));
  }

  /// Update monthly income
  Future<int> updateMonthlyIncome(double income) async {
    final profile = await getUserProfile();
    if (profile == null) {
      return await saveUserProfile(UserProfile(monthlyIncome: income));
    }
    return await saveUserProfile(profile.copyWith(monthlyIncome: income));
  }

  /// Update water goal
  Future<int> updateWaterGoal(int goal) async {
    final profile = await getUserProfile();
    if (profile == null) {
      return await saveUserProfile(UserProfile(waterGoal: goal));
    }
    return await saveUserProfile(profile.copyWith(waterGoal: goal));
  }

  /// Update profile picture path
  Future<int> updateProfilePicturePath(String? picturePath) async {
    final profile = await getUserProfile();
    if (profile == null) {
      return await saveUserProfile(UserProfile(profilePicturePath: picturePath));
    }
    return await saveUserProfile(profile.copyWith(profilePicturePath: picturePath));
  }
}

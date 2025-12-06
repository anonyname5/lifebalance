import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/tables.dart';
import '../models/meal_log.dart';

/// Repository for meal log operations
class MealRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Add a meal log entry
  Future<int> addMealLog(MealLog mealLog) async {
    final db = await _dbHelper.database;
    return await db.insert(
      Tables.mealLogs,
      mealLog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all meal logs for a specific date
  Future<List<MealLog>> getMealLogsByDate(String date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.mealLogs,
      where: '${Tables.date} = ?',
      whereArgs: [date],
      orderBy: '${Tables.time} ASC',
    );

    return List.generate(maps.length, (i) => MealLog.fromMap(maps[i]));
  }

  /// Get today's meal logs
  Future<List<MealLog>> getTodayMealLogs() async {
    final db = await _dbHelper.database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    return await getMealLogsByDate(today);
  }

  /// Delete a meal log entry
  Future<int> deleteMealLog(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      Tables.mealLogs,
      where: '${Tables.mealLogId} = ?',
      whereArgs: [id],
    );
  }

  /// Get meal logs for a date range
  Future<List<MealLog>> getMealLogsByDateRange(
    String startDate,
    String endDate,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.mealLogs,
      where: '${Tables.date} >= ? AND ${Tables.date} <= ?',
      whereArgs: [startDate, endDate],
      orderBy: '${Tables.date} DESC, ${Tables.time} ASC',
    );

    return List.generate(maps.length, (i) => MealLog.fromMap(maps[i]));
  }

  /// Filter meal logs with multiple criteria
  Future<List<MealLog>> filterMealLogs({
    String? mealType,
    String? startDate,
    String? endDate,
    String? searchQuery,
  }) async {
    final db = await _dbHelper.database;
    final List<String> whereConditions = [];
    final List<dynamic> whereArgs = [];

    if (mealType != null && mealType.isNotEmpty) {
      whereConditions.add('${Tables.mealType} = ?');
      whereArgs.add(mealType);
    }

    if (startDate != null && startDate.isNotEmpty) {
      whereConditions.add('${Tables.date} >= ?');
      whereArgs.add(startDate);
    }

    if (endDate != null && endDate.isNotEmpty) {
      whereConditions.add('${Tables.date} <= ?');
      whereArgs.add(endDate);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereConditions.add('${Tables.notes} LIKE ?');
      whereArgs.add('%$searchQuery%');
    }

    final whereClause = whereConditions.isNotEmpty
        ? whereConditions.join(' AND ')
        : null;

    final maps = await db.query(
      Tables.mealLogs,
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: '${Tables.date} DESC, ${Tables.time} ASC',
    );

    return List.generate(maps.length, (i) => MealLog.fromMap(maps[i]));
  }
}

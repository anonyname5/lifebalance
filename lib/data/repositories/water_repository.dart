import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/tables.dart';
import '../models/water_log.dart';
import '../../core/utils/date_helper.dart';

/// Repository for water log operations
class WaterRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Add a water log entry
  Future<int> addWaterLog(WaterLog waterLog) async {
    final db = await _dbHelper.database;
    return await db.insert(
      Tables.waterLogs,
      waterLog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all water logs for a specific date
  Future<List<WaterLog>> getWaterLogsByDate(String date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.waterLogs,
      where: '${Tables.date} = ?',
      whereArgs: [date],
      orderBy: '${Tables.timestamp} DESC',
    );

    return List.generate(maps.length, (i) => WaterLog.fromMap(maps[i]));
  }

  /// Get total glasses for a specific date
  Future<int> getTotalGlassesByDate(String date) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(${Tables.glasses}) as total FROM ${Tables.waterLogs} WHERE ${Tables.date} = ?',
      [date],
    );

    final total = result.first['total'];
    return total != null ? total as int : 0;
  }

  /// Get today's total glasses
  Future<int> getTodayTotalGlasses() async {
    final today = DateHelper.todayAsString();
    return await getTotalGlassesByDate(today);
  }

  /// Delete a water log entry
  Future<int> deleteWaterLog(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      Tables.waterLogs,
      where: '${Tables.waterLogId} = ?',
      whereArgs: [id],
    );
  }

  /// Get water logs for a date range
  Future<List<WaterLog>> getWaterLogsByDateRange(
    String startDate,
    String endDate,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.waterLogs,
      where: '${Tables.date} >= ? AND ${Tables.date} <= ?',
      whereArgs: [startDate, endDate],
      orderBy: '${Tables.date} DESC, ${Tables.timestamp} DESC',
    );

    return List.generate(maps.length, (i) => WaterLog.fromMap(maps[i]));
  }

  /// Filter water logs by date range
  Future<List<WaterLog>> filterWaterLogs({
    String? startDate,
    String? endDate,
  }) async {
    final db = await _dbHelper.database;
    final List<String> whereConditions = [];
    final List<dynamic> whereArgs = [];

    if (startDate != null && startDate.isNotEmpty) {
      whereConditions.add('${Tables.date} >= ?');
      whereArgs.add(startDate);
    }

    if (endDate != null && endDate.isNotEmpty) {
      whereConditions.add('${Tables.date} <= ?');
      whereArgs.add(endDate);
    }

    final whereClause = whereConditions.isNotEmpty
        ? whereConditions.join(' AND ')
        : null;

    final maps = await db.query(
      Tables.waterLogs,
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: '${Tables.date} DESC, ${Tables.timestamp} DESC',
    );

    return List.generate(maps.length, (i) => WaterLog.fromMap(maps[i]));
  }
}

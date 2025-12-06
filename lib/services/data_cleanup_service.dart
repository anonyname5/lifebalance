import 'package:sqflite/sqflite.dart';
import '../data/database/database_helper.dart';
import '../data/database/tables.dart';
import '../services/preferences_service.dart';

/// Service for deleting all user data
class DataCleanupService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Delete all data from all tables
  Future<void> deleteAllData() async {
    final db = await _dbHelper.database;

    // Delete all records from each table
    await db.delete(Tables.waterLogs);
    await db.delete(Tables.mealLogs);
    await db.delete(Tables.expenses);
    await db.delete(Tables.budgetCategories);
    await db.delete(Tables.savingsGoals);
    await db.delete(Tables.recurringExpenses);
    
    // Clear user profile (but keep the structure)
    await db.delete(Tables.userProfile);

    // Clear all preferences
    await PreferencesService.clearAll();
  }

  /// Get total record count across all tables
  Future<Map<String, int>> getDataCounts() async {
    final db = await _dbHelper.database;

    final counts = <String, int>{};

    counts['water_logs'] = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${Tables.waterLogs}'),
        ) ?? 0;
    counts['meal_logs'] = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${Tables.mealLogs}'),
        ) ?? 0;
    counts['expenses'] = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${Tables.expenses}'),
        ) ?? 0;
    counts['budget_categories'] = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${Tables.budgetCategories}'),
        ) ?? 0;
    counts['savings_goals'] = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${Tables.savingsGoals}'),
        ) ?? 0;
    counts['recurring_expenses'] = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${Tables.recurringExpenses}'),
        ) ?? 0;
    counts['user_profile'] = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${Tables.userProfile}'),
        ) ?? 0;

    return counts;
  }

  /// Get total count of all records
  Future<int> getTotalRecordCount() async {
    final counts = await getDataCounts();
    int total = 0;
    for (var count in counts.values) {
      total += count;
    }
    return total;
  }
}

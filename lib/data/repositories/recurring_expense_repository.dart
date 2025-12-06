import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/tables.dart';
import '../models/recurring_expense.dart';

/// Repository for recurring expenses operations
class RecurringExpenseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Add a recurring expense
  Future<int> addRecurringExpense(RecurringExpense expense) async {
    final db = await _dbHelper.database;
    return await db.insert(
      Tables.recurringExpenses,
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all recurring expenses
  Future<List<RecurringExpense>> getAllRecurringExpenses() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.recurringExpenses,
      orderBy: '${Tables.recurringName} ASC',
    );

    return List.generate(maps.length, (i) => RecurringExpense.fromMap(maps[i]));
  }

  /// Get active recurring expenses
  Future<List<RecurringExpense>> getActiveRecurringExpenses() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.recurringExpenses,
      where: '${Tables.isActive} = ?',
      whereArgs: [1],
      orderBy: '${Tables.recurringName} ASC',
    );

    return List.generate(maps.length, (i) => RecurringExpense.fromMap(maps[i]));
  }

  /// Get recurring expenses due today (monthly, matching day of month)
  Future<List<RecurringExpense>> getRecurringExpensesDueToday() async {
    final today = DateTime.now();
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.recurringExpenses,
      where: '${Tables.isActive} = ? AND ${Tables.frequency} = ? AND ${Tables.dayOfMonth} = ?',
      whereArgs: [1, 'monthly', today.day],
    );

    return List.generate(maps.length, (i) => RecurringExpense.fromMap(maps[i]));
  }

  /// Get a recurring expense by ID
  Future<RecurringExpense?> getRecurringExpenseById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.recurringExpenses,
      where: '${Tables.recurringExpenseId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return RecurringExpense.fromMap(maps.first);
  }

  /// Update a recurring expense
  Future<int> updateRecurringExpense(RecurringExpense expense) async {
    final db = await _dbHelper.database;
    return await db.update(
      Tables.recurringExpenses,
      expense.toMap(),
      where: '${Tables.recurringExpenseId} = ?',
      whereArgs: [expense.id],
    );
  }

  /// Delete a recurring expense (soft delete by setting isActive to 0)
  Future<int> deleteRecurringExpense(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      Tables.recurringExpenses,
      {'is_active': 0},
      where: '${Tables.recurringExpenseId} = ?',
      whereArgs: [id],
    );
  }

  /// Toggle active status
  Future<int> toggleActive(int id, bool isActive) async {
    final db = await _dbHelper.database;
    return await db.update(
      Tables.recurringExpenses,
      {'is_active': isActive ? 1 : 0},
      where: '${Tables.recurringExpenseId} = ?',
      whereArgs: [id],
    );
  }
}

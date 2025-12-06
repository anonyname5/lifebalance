import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/tables.dart';
import '../models/expense.dart';
import '../../core/utils/date_helper.dart';

/// Repository for expense operations
class ExpenseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Add an expense
  Future<int> addExpense(Expense expense) async {
    final db = await _dbHelper.database;
    return await db.insert(
      Tables.expenses,
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all expenses for a specific date
  Future<List<Expense>> getExpensesByDate(String date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.expenses,
      where: '${Tables.date} = ?',
      whereArgs: [date],
      orderBy: '${Tables.time} DESC',
    );

    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  /// Get total expenses for a specific date
  Future<double> getTotalExpensesByDate(String date) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(${Tables.amount}) as total FROM ${Tables.expenses} WHERE ${Tables.date} = ?',
      [date],
    );

    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }

  /// Get today's total expenses
  Future<double> getTodayTotalExpenses() async {
    final today = DateHelper.todayAsString();
    return await getTotalExpensesByDate(today);
  }

  /// Get expenses for current month
  Future<List<Expense>> getCurrentMonthExpenses() async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    return await getExpensesByDateRange(
      DateHelper.formatDateForDb(firstDay),
      DateHelper.formatDateForDb(lastDay),
    );
  }

  /// Get total expenses for current month
  Future<double> getCurrentMonthTotal() async {
    final expenses = await getCurrentMonthExpenses();
    double total = 0.0;
    for (var expense in expenses) {
      total += expense.amount;
    }
    return total;
  }

  /// Get expenses by category for a date range
  Future<Map<String, double>> getExpensesByCategory(String startDate, String endDate) async {
    final expenses = await getExpensesByDateRange(startDate, endDate);
    final Map<String, double> categoryTotals = {};

    for (var expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0.0) + expense.amount;
    }

    return categoryTotals;
  }

  /// Get expenses for a date range
  Future<List<Expense>> getExpensesByDateRange(
    String startDate,
    String endDate,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.expenses,
      where: '${Tables.date} >= ? AND ${Tables.date} <= ?',
      whereArgs: [startDate, endDate],
      orderBy: '${Tables.date} DESC, ${Tables.time} DESC',
    );

    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  /// Delete an expense
  Future<int> deleteExpense(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      Tables.expenses,
      where: '${Tables.expenseId} = ?',
      whereArgs: [id],
    );
  }

  /// Update an expense
  Future<int> updateExpense(Expense expense) async {
    final db = await _dbHelper.database;
    return await db.update(
      Tables.expenses,
      expense.toMap(),
      where: '${Tables.expenseId} = ?',
      whereArgs: [expense.id],
    );
  }

  /// Search expenses by description (case-insensitive)
  Future<List<Expense>> searchExpenses(String searchQuery) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.expenses,
      where: '${Tables.description} LIKE ?',
      whereArgs: ['%$searchQuery%'],
      orderBy: '${Tables.date} DESC, ${Tables.time} DESC',
    );

    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  /// Filter expenses with multiple criteria
  Future<List<Expense>> filterExpenses({
    String? category,
    String? startDate,
    String? endDate,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
  }) async {
    final db = await _dbHelper.database;
    final List<String> whereConditions = [];
    final List<dynamic> whereArgs = [];

    if (category != null && category.isNotEmpty) {
      whereConditions.add('${Tables.category} = ?');
      whereArgs.add(category);
    }

    if (startDate != null && startDate.isNotEmpty) {
      whereConditions.add('${Tables.date} >= ?');
      whereArgs.add(startDate);
    }

    if (endDate != null && endDate.isNotEmpty) {
      whereConditions.add('${Tables.date} <= ?');
      whereArgs.add(endDate);
    }

    if (minAmount != null) {
      whereConditions.add('${Tables.amount} >= ?');
      whereArgs.add(minAmount);
    }

    if (maxAmount != null) {
      whereConditions.add('${Tables.amount} <= ?');
      whereArgs.add(maxAmount);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereConditions.add('${Tables.description} LIKE ?');
      whereArgs.add('%$searchQuery%');
    }

    final whereClause = whereConditions.isNotEmpty
        ? whereConditions.join(' AND ')
        : null;

    final maps = await db.query(
      Tables.expenses,
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: '${Tables.date} DESC, ${Tables.time} DESC',
    );

    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  /// Get all expenses (for filtering/search)
  Future<List<Expense>> getAllExpenses() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.expenses,
      orderBy: '${Tables.date} DESC, ${Tables.time} DESC',
    );

    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }
}

import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/tables.dart';
import '../models/budget_category.dart';
import '../repositories/expense_repository.dart';
import '../../core/utils/date_helper.dart';

/// Repository for budget operations
class BudgetRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ExpenseRepository _expenseRepository = ExpenseRepository();

  /// Add a budget category
  Future<int> addBudgetCategory(BudgetCategory category) async {
    final db = await _dbHelper.database;
    return await db.insert(
      Tables.budgetCategories,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all budget categories
  Future<List<BudgetCategory>> getAllBudgetCategories() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.budgetCategories,
      where: '${Tables.isActive} = ?',
      whereArgs: [1],
      orderBy: '${Tables.categoryName} ASC',
    );

    return List.generate(maps.length, (i) => BudgetCategory.fromMap(maps[i]));
  }

  /// Get a budget category by name
  Future<BudgetCategory?> getBudgetCategoryByName(String name) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.budgetCategories,
      where: '${Tables.categoryName} = ? AND ${Tables.isActive} = ?',
      whereArgs: [name, 1],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return BudgetCategory.fromMap(maps.first);
  }

  /// Update a budget category
  Future<int> updateBudgetCategory(BudgetCategory category) async {
    final db = await _dbHelper.database;
    return await db.update(
      Tables.budgetCategories,
      category.toMap(),
      where: '${Tables.budgetCategoryId} = ?',
      whereArgs: [category.id],
    );
  }

  /// Delete a budget category (soft delete by setting isActive to 0)
  Future<int> deleteBudgetCategory(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      Tables.budgetCategories,
      {'is_active': 0},
      where: '${Tables.budgetCategoryId} = ?',
      whereArgs: [id],
    );
  }

  /// Get current month spending for a category
  Future<double> getCategorySpendingThisMonth(String categoryName) async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    final expenses = await _expenseRepository.getExpensesByDateRange(
      DateHelper.formatDateForDb(firstDay),
      DateHelper.formatDateForDb(lastDay),
    );

    double total = 0.0;
    for (var expense in expenses) {
      if (expense.category == categoryName) {
        total += expense.amount;
      }
    }
    return total;
  }

  /// Get budget progress for a category (spending / limit)
  Future<double> getBudgetProgress(String categoryName) async {
    final category = await getBudgetCategoryByName(categoryName);
    if (category == null) return 0.0;

    final spending = await getCategorySpendingThisMonth(categoryName);
    return spending / category.monthlyLimit;
  }

  /// Get all categories with their spending and progress
  Future<Map<BudgetCategory, Map<String, double>>> getAllCategoriesWithProgress() async {
    final categories = await getAllBudgetCategories();
    final Map<BudgetCategory, Map<String, double>> result = {};

    for (var category in categories) {
      final spending = await getCategorySpendingThisMonth(category.name);
      final progress = spending / category.monthlyLimit;
      final remaining = category.monthlyLimit - spending;

      result[category] = {
        'spending': spending,
        'progress': progress,
        'remaining': remaining,
      };
    }

    return result;
  }
}

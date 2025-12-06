import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/tables.dart';
import '../models/expense_category.dart';

/// Repository for expense category operations
class ExpenseCategoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Get all active expense categories
  Future<List<ExpenseCategory>> getAllCategories() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.expenseCategories,
      where: '${Tables.expenseCategoryIsActive} = ?',
      whereArgs: [1],
      orderBy: '${Tables.expenseCategoryIsDefault} DESC, ${Tables.expenseCategoryName} ASC',
    );

    return List.generate(maps.length, (i) => ExpenseCategory.fromMap(maps[i]));
  }

  /// Get category by name
  Future<ExpenseCategory?> getCategoryByName(String name) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.expenseCategories,
      where: '${Tables.expenseCategoryName} = ? AND ${Tables.expenseCategoryIsActive} = ?',
      whereArgs: [name, 1],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return ExpenseCategory.fromMap(maps.first);
  }

  /// Get category by ID
  Future<ExpenseCategory?> getCategoryById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.expenseCategories,
      where: '${Tables.expenseCategoryId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return ExpenseCategory.fromMap(maps.first);
  }

  /// Insert a new category
  Future<int> insertCategory(ExpenseCategory category) async {
    final db = await _dbHelper.database;
    return await db.insert(
      Tables.expenseCategories,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update a category
  Future<int> updateCategory(ExpenseCategory category) async {
    final db = await _dbHelper.database;
    return await db.update(
      Tables.expenseCategories,
      category.toMap(),
      where: '${Tables.expenseCategoryId} = ?',
      whereArgs: [category.id],
    );
  }

  /// Delete a category (soft delete by setting is_active = 0)
  Future<int> deleteCategory(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      Tables.expenseCategories,
      {Tables.expenseCategoryIsActive: 0},
      where: '${Tables.expenseCategoryId} = ?',
      whereArgs: [id],
    );
  }

  /// Check if category name exists
  Future<bool> categoryNameExists(String name, {int? excludeId}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.expenseCategories,
      where: excludeId != null
          ? '${Tables.expenseCategoryName} = ? AND ${Tables.expenseCategoryId} != ?'
          : '${Tables.expenseCategoryName} = ?',
      whereArgs: excludeId != null ? [name, excludeId] : [name],
      limit: 1,
    );

    return maps.isNotEmpty;
  }
}

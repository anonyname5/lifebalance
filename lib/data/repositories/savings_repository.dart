import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/tables.dart';
import '../models/savings_goal.dart';

/// Repository for savings goals operations
class SavingsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Add a savings goal
  Future<int> addSavingsGoal(SavingsGoal goal) async {
    final db = await _dbHelper.database;
    return await db.insert(
      Tables.savingsGoals,
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all savings goals
  Future<List<SavingsGoal>> getAllSavingsGoals() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.savingsGoals,
      orderBy: '${Tables.createdAt} DESC',
    );

    return List.generate(maps.length, (i) => SavingsGoal.fromMap(maps[i]));
  }

  /// Get active (non-completed) savings goals
  Future<List<SavingsGoal>> getActiveSavingsGoals() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.savingsGoals,
      where: '${Tables.isCompleted} = ?',
      whereArgs: [0],
      orderBy: '${Tables.createdAt} DESC',
    );

    return List.generate(maps.length, (i) => SavingsGoal.fromMap(maps[i]));
  }

  /// Get a savings goal by ID
  Future<SavingsGoal?> getSavingsGoalById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      Tables.savingsGoals,
      where: '${Tables.savingsGoalId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return SavingsGoal.fromMap(maps.first);
  }

  /// Update a savings goal
  Future<int> updateSavingsGoal(SavingsGoal goal) async {
    final db = await _dbHelper.database;
    return await db.update(
      Tables.savingsGoals,
      goal.toMap(),
      where: '${Tables.savingsGoalId} = ?',
      whereArgs: [goal.id],
    );
  }

  /// Add amount to a savings goal
  Future<int> addToSavingsGoal(int id, double amount) async {
    final goal = await getSavingsGoalById(id);
    if (goal == null) return 0;

    final newAmount = goal.currentAmount + amount;
    final isCompleted = newAmount >= goal.targetAmount ? 1 : goal.isCompleted;

    final updatedGoal = goal.copyWith(
      currentAmount: newAmount,
      isCompleted: isCompleted,
    );

    return await updateSavingsGoal(updatedGoal);
  }

  /// Delete a savings goal
  Future<int> deleteSavingsGoal(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      Tables.savingsGoals,
      where: '${Tables.savingsGoalId} = ?',
      whereArgs: [id],
    );
  }

  /// Mark a savings goal as completed
  Future<int> completeSavingsGoal(int id) async {
    final goal = await getSavingsGoalById(id);
    if (goal == null) return 0;

    final updatedGoal = goal.copyWith(isCompleted: 1);
    return await updateSavingsGoal(updatedGoal);
  }
}

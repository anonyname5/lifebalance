import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'tables.dart';

/// Database helper class for SQLite operations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lifebalance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // User Profile Table
    await db.execute('''
      CREATE TABLE ${Tables.userProfile} (
        ${Tables.userId} INTEGER PRIMARY KEY,
        ${Tables.userName} TEXT,
        ${Tables.monthlyIncome} REAL,
        ${Tables.waterGoal} INTEGER DEFAULT 8,
        ${Tables.profilePicturePath} TEXT,
        ${Tables.createdAt} TEXT,
        ${Tables.updatedAt} TEXT
      )
    ''');

    // Water Logs Table
    await db.execute('''
      CREATE TABLE ${Tables.waterLogs} (
        ${Tables.waterLogId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.date} TEXT NOT NULL,
        ${Tables.glasses} INTEGER DEFAULT 1,
        ${Tables.timestamp} TEXT NOT NULL,
        ${Tables.createdAt} TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Meal Logs Table
    await db.execute('''
      CREATE TABLE ${Tables.mealLogs} (
        ${Tables.mealLogId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.mealType} TEXT,
        ${Tables.date} TEXT NOT NULL,
        ${Tables.time} TEXT NOT NULL,
        ${Tables.notes} TEXT,
        ${Tables.createdAt} TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Expenses Table
    await db.execute('''
      CREATE TABLE ${Tables.expenses} (
        ${Tables.expenseId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.amount} REAL NOT NULL,
        ${Tables.category} TEXT NOT NULL,
        ${Tables.description} TEXT,
        ${Tables.date} TEXT NOT NULL,
        ${Tables.time} TEXT NOT NULL,
        ${Tables.receiptPhotoPath} TEXT,
        ${Tables.createdAt} TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Budget Categories Table
    await db.execute('''
      CREATE TABLE ${Tables.budgetCategories} (
        ${Tables.budgetCategoryId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.categoryName} TEXT UNIQUE NOT NULL,
        ${Tables.monthlyLimit} REAL NOT NULL,
        ${Tables.color} TEXT,
        ${Tables.icon} TEXT,
        ${Tables.isActive} INTEGER DEFAULT 1
      )
    ''');

    // Savings Goals Table
    await db.execute('''
      CREATE TABLE ${Tables.savingsGoals} (
        ${Tables.savingsGoalId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.goalName} TEXT NOT NULL,
        ${Tables.targetAmount} REAL NOT NULL,
        ${Tables.currentAmount} REAL DEFAULT 0,
        ${Tables.targetDate} TEXT,
        ${Tables.isCompleted} INTEGER DEFAULT 0,
        ${Tables.createdAt} TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Recurring Expenses Table
    await db.execute('''
      CREATE TABLE ${Tables.recurringExpenses} (
        ${Tables.recurringExpenseId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.recurringName} TEXT NOT NULL,
        ${Tables.recurringAmount} REAL NOT NULL,
        ${Tables.recurringCategory} TEXT NOT NULL,
        ${Tables.frequency} TEXT,
        ${Tables.dayOfMonth} INTEGER,
        ${Tables.isActive} INTEGER DEFAULT 1
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX idx_expenses_date ON ${Tables.expenses}(${Tables.date})
    ''');

    await db.execute('''
      CREATE INDEX idx_water_logs_date ON ${Tables.waterLogs}(${Tables.date})
    ''');

    await db.execute('''
      CREATE INDEX idx_meal_logs_date ON ${Tables.mealLogs}(${Tables.date})
    ''');

    // Expense Categories Table
    await db.execute('''
      CREATE TABLE ${Tables.expenseCategories} (
        ${Tables.expenseCategoryId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.expenseCategoryName} TEXT UNIQUE NOT NULL,
        ${Tables.iconName} TEXT NOT NULL,
        ${Tables.colorHex} TEXT NOT NULL,
        ${Tables.expenseCategoryIsDefault} INTEGER DEFAULT 0,
        ${Tables.expenseCategoryIsActive} INTEGER DEFAULT 1
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {'name': 'Food', 'icon': Icons.restaurant.codePoint.toString(), 'color': '#FF6B6B'},
      {'name': 'Transport', 'icon': Icons.directions_car.codePoint.toString(), 'color': '#4ECDC4'},
      {'name': 'Shopping', 'icon': Icons.shopping_bag.codePoint.toString(), 'color': '#45B7D1'},
      {'name': 'Entertainment', 'icon': Icons.movie.codePoint.toString(), 'color': '#FFA07A'},
      {'name': 'Bills', 'icon': Icons.receipt.codePoint.toString(), 'color': '#98D8C8'},
      {'name': 'Health', 'icon': Icons.medical_services.codePoint.toString(), 'color': '#F7DC6F'},
      {'name': 'Education', 'icon': Icons.school.codePoint.toString(), 'color': '#BB8FCE'},
      {'name': 'Other', 'icon': Icons.category.codePoint.toString(), 'color': '#85C1E2'},
    ];

    for (final category in defaultCategories) {
      await db.insert(
        Tables.expenseCategories,
        {
          Tables.expenseCategoryName: category['name'],
          Tables.iconName: category['icon'],
          Tables.colorHex: category['color'],
          Tables.expenseCategoryIsDefault: 1,
          Tables.expenseCategoryIsActive: 1,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add expense_categories table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${Tables.expenseCategories} (
          ${Tables.expenseCategoryId} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${Tables.expenseCategoryName} TEXT UNIQUE NOT NULL,
          ${Tables.iconName} TEXT NOT NULL,
          ${Tables.colorHex} TEXT NOT NULL,
          ${Tables.expenseCategoryIsDefault} INTEGER DEFAULT 0,
          ${Tables.expenseCategoryIsActive} INTEGER DEFAULT 1
        )
      ''');

      // Insert default categories
      await _insertDefaultCategories(db);
    }
    
    if (oldVersion < 4) {
      // Add receipt_photo_path column to expenses table
      try {
        await db.execute('''
          ALTER TABLE ${Tables.expenses} 
          ADD COLUMN ${Tables.receiptPhotoPath} TEXT
        ''');
      } catch (e) {
        // Column might already exist, ignore error
      }
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}

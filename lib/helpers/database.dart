import 'package:budget_tracker_app/models/category.dart';
import 'package:budget_tracker_app/models/transaction.dart' as transaction;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

class DatabaseHelper {
  static const _dbName = 'budget_tracker.db';
  static const _dbVersion = 2;

  static const transactionTable = 'transactions';
  static const categoryTable = 'categories';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initiateDatabase();
    return _database!;
  }

  Future<Database> _initiateDatabase() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $categoryTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        isDefault INTEGER NOT NULL DEFAULT 0,
        iconName TEXT NOT NULL DEFAULT 'category'
      )
    ''');

    await db.execute('''
      CREATE TABLE $transactionTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    // Insert default categories
    await insertCategory(db, Category(name: 'Utilities', isDefault: true, iconName: 'home'));
    await insertCategory(db, Category(name: 'Food', isDefault: true, iconName: 'fast_food'));
    await insertCategory(db, Category(name: 'Transportation', isDefault: true, iconName: 'bus'));
    await insertCategory(db, Category(name: 'Housing', isDefault: true, iconName: 'default'));
    await insertCategory(db, Category(name: 'Entertainment', isDefault: true, iconName: 'movie'));
    await insertCategory(db, Category(name: 'Salary', isDefault: true, iconName: 'money'));
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add iconName column to categories table
      await db.execute('''
        ALTER TABLE $categoryTable 
        ADD COLUMN iconName TEXT NOT NULL DEFAULT 'default'
      ''');

      // Update existing categories to have the default icon
      await db.execute('''
        UPDATE $categoryTable 
        SET iconName = 'default'
      ''');
    }
  }

  // Category CRUD Operations
  Future<int> insertCategory(Database db, Category category) async {
    return await db.insert(categoryTable, category.toMap());
  }

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(categoryTable);
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      categoryTable,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      categoryTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Transaction CRUD Operations
  Future<int> insertTransaction(transaction.Transaction transaction) async {
    final db = await database;
    return await db.insert(transactionTable, transaction.toMap());
  }

  Future<List<transaction.Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(transactionTable);
    return List.generate(maps.length, (i) {
      return transaction.Transaction.fromMap(maps[i]);
    });
  }

  Future<List<transaction.Transaction>> getTransactionsForMonth(DateTime month) async {
    final db = await database;
    DateTime startOfMonth = DateTime(month.year, month.month, 1);
    DateTime endOfMonth = DateTime(month.year, month.month + 1, 0); // Last day of the month

    final List<Map<String, dynamic>> maps = await db.query(
      transactionTable,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
    );

    return List.generate(maps.length, (i) {
      return transaction.Transaction.fromMap(maps[i]);
    });
  }

  Future<int> updateTransaction(transaction.Transaction transaction) async {
    final db = await database;
    return await db.update(
      transactionTable,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      transactionTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

Future<double> getTotalExpensesForMonth(DateTime month) async {
    final db = await database;
    DateTime startOfMonth = DateTime(month.year, month.month, 1);
    DateTime endOfMonth = DateTime(month.year, month.month + 1, 0);

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT SUM(amount) FROM $transactionTable
    WHERE type = 'Expense' AND date >= ? AND date <= ?
    ''', [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()]);

    return result.first['SUM(amount)'] as double? ?? 0.0;
  }

  Future<double> getTotalIncomeForMonth(DateTime month) async {
    final db = await database;
    DateTime startOfMonth = DateTime(month.year, month.month, 1);
    DateTime endOfMonth = DateTime(month.year, month.month + 1, 0);

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT SUM(amount) FROM $transactionTable
    WHERE type = 'Income' AND date >= ? AND date <= ?
    ''', [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()]);

    return result.first['SUM(amount)'] as double? ?? 0.0;
  }

  Future<Map<String, double>> getCategoryWiseExpensesForMonth(DateTime month) async {
    final db = await database;
    DateTime startOfMonth = DateTime(month.year, month.month, 1);
    DateTime endOfMonth = DateTime(month.year, month.month + 1, 0);

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT category, SUM(amount) FROM $transactionTable
    WHERE type = 'Expense' AND date >= ? AND date <= ?
    GROUP BY category
    ''', [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()]);

    Map<String, double> categoryExpenses = {};
    for (var row in result) {
      categoryExpenses[row['category'] as String] = row['SUM(amount)'] as double;
    }

    return categoryExpenses;
  }

  Future<bool> categoryHasTransactions(String categoryName) async {
    final db = await database;
    final result = await db.query(
      transactionTable,
      where: 'category = ?',
      whereArgs: [categoryName],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> deleteTransactionsByCategory(String categoryName) async {
    final db = await database;
    await db.delete(
      transactionTable,
      where: 'category = ?',
      whereArgs: [categoryName],
    );
  }
}
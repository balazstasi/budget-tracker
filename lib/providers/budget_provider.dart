import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:budget_tracker_app/helpers/database.dart';
import 'package:budget_tracker_app/models/transaction.dart' as transaction;
import 'package:budget_tracker_app/models/category.dart' as category;

class BudgetProvider with ChangeNotifier {
  List<transaction.Transaction> _transactions = [];
  List<category.Category> _categories = [];
  DateTime _selectedMonth = DateTime.now();
  final dbHelper = DatabaseHelper.instance;

  List<transaction.Transaction> get transactions => _transactions;
  List<category.Category> get categories => _categories;
  DateTime get selectedMonth => _selectedMonth;

  double _totalExpenses = 0.0;
  double _totalIncome = 0.0;

  double get totalExpenses => _totalExpenses;
  double get totalIncome => _totalIncome;

  Map<String, double> _categoryWiseExpenses = {};
  Map<String, double> get categoryWiseExpenses => _categoryWiseExpenses;

  BudgetProvider() {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await fetchTransactionsForMonth(_selectedMonth);
    await fetchCategories();
    await calculateTotals(_selectedMonth);
    await fetchCategoryWiseExpenses(_selectedMonth);
  }

  Future<void> fetchTransactionsForMonth(DateTime month) async {
    _transactions = await dbHelper.getTransactionsForMonth(month);
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    _categories = await dbHelper.getAllCategories();
    notifyListeners();
  }

  Future<void> addTransaction(transaction.Transaction transaction) async {
    await dbHelper.insertTransaction(transaction);
    await fetchTransactionsForMonth(_selectedMonth); // Refresh list
    await calculateTotals(_selectedMonth);
    await fetchCategoryWiseExpenses(_selectedMonth);
    notifyListeners();
  }

  Future<void> addCategory(category.Category category) async {
    await dbHelper.insertCategory(await dbHelper.database, category);
    await fetchCategories();
    notifyListeners();
  }

  Future<void> updateCategory(category.Category category) async {
    await dbHelper.updateCategory(category);
    await fetchCategories();
    notifyListeners();
  }

  Future<void> deleteCategory(int id) async {
    final category = _categories.firstWhere((cat) => cat.id == id);
    await dbHelper.deleteCategory(id);
    // Delete all transactions associated with this category
    await dbHelper.deleteTransactionsByCategory(category.name);
    await fetchCategories();
    await fetchTransactionsForMonth(_selectedMonth);
    await calculateTotals(_selectedMonth);
    await fetchCategoryWiseExpenses(_selectedMonth);
    notifyListeners();
  }

  Future<void> updateTransaction(transaction.Transaction transaction) async {
    await dbHelper.updateTransaction(transaction);
    await fetchTransactionsForMonth(_selectedMonth);
    await calculateTotals(_selectedMonth);
    await fetchCategoryWiseExpenses(_selectedMonth);
    notifyListeners();
  }

  Future<void> deleteTransaction(int id) async {
    await dbHelper.deleteTransaction(id);
    await fetchTransactionsForMonth(_selectedMonth);
    await calculateTotals(_selectedMonth);
    await fetchCategoryWiseExpenses(_selectedMonth);
    notifyListeners();
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    fetchTransactionsForMonth(month);
    calculateTotals(month);
    fetchCategoryWiseExpenses(month);
    notifyListeners();
  }

  Future<void> calculateTotals(DateTime month) async {
    _totalExpenses = await dbHelper.getTotalExpensesForMonth(month);
    _totalIncome = await dbHelper.getTotalIncomeForMonth(month);
    notifyListeners();
  }

  Future<void> fetchCategoryWiseExpenses(DateTime month) async {
    _categoryWiseExpenses = await dbHelper.getCategoryWiseExpensesForMonth(month);
    notifyListeners();
  }

  String getFormattedDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Future<bool> categoryHasTransactions(String categoryName) async {
    return await dbHelper.categoryHasTransactions(categoryName);
  }
}
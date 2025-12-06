import '../data/repositories/recurring_expense_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../data/models/recurring_expense.dart';
import '../data/models/expense.dart';
import '../core/utils/date_helper.dart';

/// Service for handling recurring expense auto-logging
class RecurringExpenseService {
  final RecurringExpenseRepository _recurringRepository =
      RecurringExpenseRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();

  /// Check and auto-log recurring expenses due today
  Future<void> checkAndLogRecurringExpenses() async {
    try {
      final dueExpenses = await _recurringRepository.getRecurringExpensesDueToday();

      for (var recurringExpense in dueExpenses) {
        // Check if already logged today
        final today = DateHelper.todayAsString();
        final todayExpenses = await _expenseRepository.getExpensesByDate(today);

        // Check if this recurring expense was already logged today
        final alreadyLogged = todayExpenses.any((expense) =>
            expense.description == recurringExpense.name &&
            expense.amount == recurringExpense.amount &&
            expense.category == recurringExpense.category);

        if (!alreadyLogged) {
          // Auto-log the expense
          final now = DateTime.now();
          final expense = Expense(
            amount: recurringExpense.amount,
            category: recurringExpense.category,
            description: recurringExpense.name,
            date: DateHelper.formatDateForDb(now),
            time: DateHelper.formatTimeForDb(now),
          );

          await _expenseRepository.addExpense(expense);
        }
      }
    } catch (e) {
      // Silently fail - don't interrupt app startup
      print('Error auto-logging recurring expenses: $e');
    }
  }

  /// Manually log a recurring expense
  Future<void> logRecurringExpense(RecurringExpense recurringExpense) async {
    final now = DateTime.now();
    final expense = Expense(
      amount: recurringExpense.amount,
      category: recurringExpense.category,
      description: recurringExpense.name,
      date: DateHelper.formatDateForDb(now),
      time: DateHelper.formatTimeForDb(now),
    );

    await _expenseRepository.addExpense(expense);
  }
}

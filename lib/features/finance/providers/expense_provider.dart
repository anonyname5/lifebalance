import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/models/expense.dart';
import '../../../core/utils/date_helper.dart';
import '../widgets/expense_filter_widget.dart';

/// Expense repository provider
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

/// Today's expenses provider
final todayExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  final today = DateHelper.todayAsString();
  return await repository.getExpensesByDate(today);
});

/// Today's total expenses provider
final todayTotalExpensesProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getTodayTotalExpenses();
});

/// Current month total expenses provider
final currentMonthTotalProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getCurrentMonthTotal();
});

/// Expense provider for managing expenses
class ExpenseNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final ExpenseRepository _repository;
  final String _date;

  ExpenseNotifier(this._repository, this._date)
      : super(const AsyncValue.loading()) {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final expenses = await _repository.getExpensesByDate(_date);
      state = AsyncValue.data(expenses);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _repository.addExpense(expense);
      await _loadExpenses();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _repository.deleteExpense(id);
      await _loadExpenses();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadExpenses();
  }
}

/// Expense notifier provider factory
final expenseNotifierProvider = StateNotifierProvider.family<
    ExpenseNotifier, AsyncValue<List<Expense>>, String>(
  (ref, date) {
    final repository = ref.watch(expenseRepositoryProvider);
    return ExpenseNotifier(repository, date);
  },
);

/// Filtered expenses provider
final filteredExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  final filter = ref.watch(expenseFilterProvider);
  
  return await repository.filterExpenses(
    category: filter.category,
    startDate: filter.startDate != null
        ? DateHelper.formatDateForDb(filter.startDate!)
        : null,
    endDate: filter.endDate != null
        ? DateHelper.formatDateForDb(filter.endDate!)
        : null,
    minAmount: filter.minAmount,
    maxAmount: filter.maxAmount,
    searchQuery: filter.searchQuery,
  );
});

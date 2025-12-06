import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/recurring_expense_repository.dart';
import '../../../data/models/recurring_expense.dart';

/// Recurring expense repository provider
final recurringExpenseRepositoryProvider =
    Provider<RecurringExpenseRepository>((ref) {
  return RecurringExpenseRepository();
});

/// All recurring expenses provider
final recurringExpensesProvider =
    FutureProvider<List<RecurringExpense>>((ref) async {
  final repository = ref.watch(recurringExpenseRepositoryProvider);
  return await repository.getAllRecurringExpenses();
});

/// Active recurring expenses provider
final activeRecurringExpensesProvider =
    FutureProvider<List<RecurringExpense>>((ref) async {
  final repository = ref.watch(recurringExpenseRepositoryProvider);
  return await repository.getActiveRecurringExpenses();
});

/// Recurring expense provider for managing recurring expenses
class RecurringExpenseNotifier
    extends StateNotifier<AsyncValue<List<RecurringExpense>>> {
  final RecurringExpenseRepository _repository;

  RecurringExpenseNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final expenses = await _repository.getAllRecurringExpenses();
      state = AsyncValue.data(expenses);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addRecurringExpense(RecurringExpense expense) async {
    try {
      await _repository.addRecurringExpense(expense);
      await _loadExpenses();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateRecurringExpense(RecurringExpense expense) async {
    try {
      await _repository.updateRecurringExpense(expense);
      await _loadExpenses();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteRecurringExpense(int id) async {
    try {
      await _repository.deleteRecurringExpense(id);
      await _loadExpenses();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggleActive(int id, bool isActive) async {
    try {
      await _repository.toggleActive(id, isActive);
      await _loadExpenses();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadExpenses();
  }
}

/// Recurring expense notifier provider
final recurringExpenseNotifierProvider = StateNotifierProvider<
    RecurringExpenseNotifier, AsyncValue<List<RecurringExpense>>>(
  (ref) {
    final repository = ref.watch(recurringExpenseRepositoryProvider);
    return RecurringExpenseNotifier(repository);
  },
);

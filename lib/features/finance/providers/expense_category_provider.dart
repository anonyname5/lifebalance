import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/expense_category_repository.dart';
import '../../../data/models/expense_category.dart';

/// Provider for expense category repository
final expenseCategoryRepositoryProvider = Provider<ExpenseCategoryRepository>((ref) {
  return ExpenseCategoryRepository();
});

/// Provider for all expense categories
final expenseCategoriesProvider = FutureProvider<List<ExpenseCategory>>((ref) async {
  final repository = ref.watch(expenseCategoryRepositoryProvider);
  return await repository.getAllCategories();
});

/// Provider for expense category notifier
final expenseCategoryNotifierProvider = StateNotifierProvider<ExpenseCategoryNotifier, AsyncValue<List<ExpenseCategory>>>((ref) {
  final repository = ref.watch(expenseCategoryRepositoryProvider);
  return ExpenseCategoryNotifier(repository, ref);
});

class ExpenseCategoryNotifier extends StateNotifier<AsyncValue<List<ExpenseCategory>>> {
  final ExpenseCategoryRepository _repository;
  final Ref _ref;

  ExpenseCategoryNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _repository.getAllCategories();
      state = AsyncValue.data(categories);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addCategory(ExpenseCategory category) async {
    try {
      await _repository.insertCategory(category);
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCategory(ExpenseCategory category) async {
    try {
      await _repository.updateCategory(category);
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _repository.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/budget_repository.dart';
import '../../../data/models/budget_category.dart';

/// Budget repository provider
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

/// All budget categories provider
final budgetCategoriesProvider = FutureProvider<List<BudgetCategory>>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  return await repository.getAllBudgetCategories();
});

/// Budget categories with progress provider
final budgetProgressProvider = FutureProvider<
    Map<BudgetCategory, Map<String, double>>>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  return await repository.getAllCategoriesWithProgress();
});

/// Budget provider for managing budget categories
class BudgetNotifier extends StateNotifier<AsyncValue<List<BudgetCategory>>> {
  final BudgetRepository _repository;

  BudgetNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _repository.getAllBudgetCategories();
      state = AsyncValue.data(categories);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addCategory(BudgetCategory category) async {
    try {
      await _repository.addBudgetCategory(category);
      await _loadCategories();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateCategory(BudgetCategory category) async {
    try {
      await _repository.updateBudgetCategory(category);
      await _loadCategories();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _repository.deleteBudgetCategory(id);
      await _loadCategories();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadCategories();
  }
}

/// Budget notifier provider
final budgetNotifierProvider =
    StateNotifierProvider<BudgetNotifier, AsyncValue<List<BudgetCategory>>>(
  (ref) {
    final repository = ref.watch(budgetRepositoryProvider);
    return BudgetNotifier(repository);
  },
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/savings_repository.dart';
import '../../../data/models/savings_goal.dart';

/// Savings repository provider
final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  return SavingsRepository();
});

/// All savings goals provider
final savingsGoalsProvider = FutureProvider<List<SavingsGoal>>((ref) async {
  final repository = ref.watch(savingsRepositoryProvider);
  return await repository.getAllSavingsGoals();
});

/// Active savings goals provider
final activeSavingsGoalsProvider = FutureProvider<List<SavingsGoal>>((ref) async {
  final repository = ref.watch(savingsRepositoryProvider);
  return await repository.getActiveSavingsGoals();
});

/// Savings provider for managing savings goals
class SavingsNotifier extends StateNotifier<AsyncValue<List<SavingsGoal>>> {
  final SavingsRepository _repository;

  SavingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      final goals = await _repository.getAllSavingsGoals();
      state = AsyncValue.data(goals);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addGoal(SavingsGoal goal) async {
    try {
      await _repository.addSavingsGoal(goal);
      await _loadGoals();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateGoal(SavingsGoal goal) async {
    try {
      await _repository.updateSavingsGoal(goal);
      await _loadGoals();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addToGoal(int id, double amount) async {
    try {
      await _repository.addToSavingsGoal(id, amount);
      await _loadGoals();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteGoal(int id) async {
    try {
      await _repository.deleteSavingsGoal(id);
      await _loadGoals();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> completeGoal(int id) async {
    try {
      await _repository.completeSavingsGoal(id);
      await _loadGoals();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadGoals();
  }
}

/// Savings notifier provider
final savingsNotifierProvider =
    StateNotifierProvider<SavingsNotifier, AsyncValue<List<SavingsGoal>>>(
  (ref) {
    final repository = ref.watch(savingsRepositoryProvider);
    return SavingsNotifier(repository);
  },
);

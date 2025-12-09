import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/meal_repository.dart';
import '../../../data/models/meal_log.dart';
import '../../../core/utils/date_helper.dart';
import '../../../services/widget_service.dart';
import '../widgets/meal_filter_widget.dart';

/// Meal repository provider
final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return MealRepository();
});

/// Today's meal logs provider
final todayMealLogsProvider = FutureProvider<List<MealLog>>((ref) async {
  final repository = ref.watch(mealRepositoryProvider);
  final today = DateHelper.todayAsString();
  return await repository.getMealLogsByDate(today);
});

/// Meal provider for managing meal logs
class MealNotifier extends StateNotifier<AsyncValue<List<MealLog>>> {
  final MealRepository _repository;
  final String _date;

  MealNotifier(this._repository, this._date)
      : super(const AsyncValue.loading()) {
    _loadMealLogs();
  }

  Future<void> _loadMealLogs() async {
    try {
      final logs = await _repository.getMealLogsByDate(_date);
      state = AsyncValue.data(logs);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addMeal({
    required String mealType,
    required DateTime dateTime,
    String? notes,
  }) async {
    try {
      final mealLog = MealLog(
        mealType: mealType,
        date: DateHelper.formatDateForDb(dateTime),
        time: DateHelper.formatTimeForDb(dateTime),
        notes: notes,
      );

      await _repository.addMealLog(mealLog);
      await _loadMealLogs();
      
      // Update widget
      await WidgetService.updateWidget();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteMeal(int id) async {
    try {
      await _repository.deleteMealLog(id);
      await _loadMealLogs();
      
      // Update widget
      await WidgetService.updateWidget();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadMealLogs();
  }
}

/// Meal notifier provider factory
final mealNotifierProvider = StateNotifierProvider.family<
    MealNotifier, AsyncValue<List<MealLog>>, String>(
  (ref, date) {
    final repository = ref.watch(mealRepositoryProvider);
    return MealNotifier(repository, date);
  },
);

/// Filtered meal logs provider
final filteredMealLogsProvider = FutureProvider<List<MealLog>>((ref) async {
  final repository = ref.watch(mealRepositoryProvider);
  final filter = ref.watch(mealFilterProvider);
  
  return await repository.filterMealLogs(
    mealType: filter.mealType,
    startDate: filter.startDate != null
        ? DateHelper.formatDateForDb(filter.startDate!)
        : null,
    endDate: filter.endDate != null
        ? DateHelper.formatDateForDb(filter.endDate!)
        : null,
    searchQuery: filter.searchQuery,
  );
});

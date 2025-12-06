import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/water_repository.dart';
import '../../../data/models/water_log.dart';
import '../../../core/utils/date_helper.dart';

/// Water repository provider
final waterRepositoryProvider = Provider<WaterRepository>((ref) {
  return WaterRepository();
});

/// Today's water logs provider
final todayWaterLogsProvider = FutureProvider<List<WaterLog>>((ref) async {
  final repository = ref.watch(waterRepositoryProvider);
  final today = DateHelper.todayAsString();
  return await repository.getWaterLogsByDate(today);
});

/// Today's total glasses provider
final todayTotalGlassesProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(waterRepositoryProvider);
  return await repository.getTodayTotalGlasses();
});

/// Water provider for managing water logs
class WaterNotifier extends StateNotifier<AsyncValue<List<WaterLog>>> {
  final WaterRepository _repository;
  final String _date;

  WaterNotifier(this._repository, this._date)
      : super(const AsyncValue.loading()) {
    _loadWaterLogs();
  }

  Future<void> _loadWaterLogs() async {
    try {
      final logs = await _repository.getWaterLogsByDate(_date);
      state = AsyncValue.data(logs);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addWater(int glasses) async {
    try {
      final now = DateTime.now();
      final waterLog = WaterLog(
        date: DateHelper.formatDateForDb(now),
        glasses: glasses,
        timestamp: DateHelper.formatTimeForDb(now),
      );

      await _repository.addWaterLog(waterLog);
      await _loadWaterLogs();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteWater(int id) async {
    try {
      await _repository.deleteWaterLog(id);
      await _loadWaterLogs();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadWaterLogs();
  }
}

/// Water notifier provider factory
final waterNotifierProvider = StateNotifierProvider.family<
    WaterNotifier, AsyncValue<List<WaterLog>>, String>(
  (ref, date) {
    final repository = ref.watch(waterRepositoryProvider);
    return WaterNotifier(repository, date);
  },
);

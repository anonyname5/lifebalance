import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/wellness_score_service.dart';

/// Wellness score service provider
final wellnessScoreServiceProvider = Provider<WellnessScoreService>((ref) {
  return WellnessScoreService();
});

/// Daily wellness score provider
final dailyWellnessScoreProvider = FutureProvider.family<double, DateTime>((ref, date) async {
  final service = ref.watch(wellnessScoreServiceProvider);
  return await service.calculateDailyScore(date);
});

/// Weekly wellness score provider
final weeklyWellnessScoreProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(wellnessScoreServiceProvider);
  return await service.calculateWeeklyScore();
});

/// Monthly wellness score provider
final monthlyWellnessScoreProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(wellnessScoreServiceProvider);
  return await service.calculateMonthlyScore();
});

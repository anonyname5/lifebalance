import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/streak_service.dart';

/// Streak service provider
final streakServiceProvider = Provider<StreakService>((ref) {
  return StreakService();
});

/// Overall streak provider
final overallStreakProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(streakServiceProvider);
  return await service.getOverallStreak();
});

/// Water streak provider
final waterStreakProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(streakServiceProvider);
  return await service.getWaterStreak();
});

/// Meal streak provider
final mealStreakProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(streakServiceProvider);
  return await service.getMealStreak();
});

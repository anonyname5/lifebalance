import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/analytics_service.dart';

/// Analytics service provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Spending trend provider
final spendingTrendProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getSpendingTrend(months: 6);
});

/// Water trend provider
final waterTrendProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getWaterTrend(days: 30);
});

/// Monthly spending prediction provider
final monthlySpendingPredictionProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.predictMonthlySpending();
});

/// Category comparison provider
final categoryComparisonProvider =
    FutureProvider<Map<String, Map<String, double>>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getCategoryComparison();
});

/// Meal frequency trend provider
final mealFrequencyTrendProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getMealFrequencyTrend(days: 30);
});

/// Insights provider
final insightsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getInsights();
});

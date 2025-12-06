import '../data/repositories/water_repository.dart';
import '../data/repositories/meal_repository.dart';
import '../core/utils/date_helper.dart';

/// Service for tracking streaks
class StreakService {
  final WaterRepository _waterRepository = WaterRepository();
  final MealRepository _mealRepository = MealRepository();

  /// Get current water intake streak
  Future<int> getWaterStreak() async {
    int streak = 0;
    DateTime currentDate = DateTime.now();

    while (true) {
      final dateString = DateHelper.formatDateForDb(currentDate);
      final totalGlasses = await _waterRepository.getTotalGlassesByDate(dateString);
      
      // Check if user has a water goal
      final waterGoal = 8; // Default, can be fetched from preferences
      
      // If they met their goal today, increment streak
      if (totalGlasses >= waterGoal) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Get longest water intake streak
  Future<int> getLongestWaterStreak() async {
    // Get all water logs grouped by date
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 365));
    
    final waterLogs = await _waterRepository.getWaterLogsByDateRange(
      DateHelper.formatDateForDb(startDate),
      DateHelper.formatDateForDb(endDate),
    );

    // Group by date and calculate daily totals
    final Map<String, int> dailyTotals = {};
    for (var log in waterLogs) {
      dailyTotals[log.date] = (dailyTotals[log.date] ?? 0) + log.glasses;
    }

    // Calculate longest streak
    int longestStreak = 0;
    int currentStreak = 0;
    final waterGoal = 8; // Default goal

    // Sort dates
    final sortedDates = dailyTotals.keys.toList()..sort();
    
    for (var dateStr in sortedDates.reversed) {
      if (dailyTotals[dateStr]! >= waterGoal) {
        currentStreak++;
        longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
      } else {
        currentStreak = 0;
      }
    }

    return longestStreak;
  }

  /// Get current meal logging streak (days with at least one meal logged)
  Future<int> getMealStreak() async {
    int streak = 0;
    DateTime currentDate = DateTime.now();

    while (true) {
      final dateString = DateHelper.formatDateForDb(currentDate);
      final mealLogs = await _mealRepository.getMealLogsByDate(dateString);
      
      // If they logged at least one meal today, increment streak
      if (mealLogs.isNotEmpty) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Get longest meal logging streak
  Future<int> getLongestMealStreak() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 365));
    
    final mealLogs = await _mealRepository.getMealLogsByDateRange(
      DateHelper.formatDateForDb(startDate),
      DateHelper.formatDateForDb(endDate),
    );

    // Group by date
    final Set<String> datesWithMeals = {};
    for (var log in mealLogs) {
      datesWithMeals.add(log.date);
    }

    // Calculate longest streak
    int longestStreak = 0;
    int currentStreak = 0;

    // Sort dates
    final sortedDates = datesWithMeals.toList()..sort();
    
    DateTime? lastDate;
    for (var dateStr in sortedDates.reversed) {
      final date = DateHelper.parseDateFromDb(dateStr);
      
      if (lastDate == null) {
        currentStreak = 1;
      } else {
        final daysDiff = lastDate.difference(date).inDays;
        if (daysDiff == 1) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
      }
      
      longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
      lastDate = date;
    }

    return longestStreak;
  }

  /// Get overall streak (combination of water and meals)
  Future<Map<String, dynamic>> getOverallStreak() async {
    final waterStreak = await getWaterStreak();
    final mealStreak = await getMealStreak();
    final longestWaterStreak = await getLongestWaterStreak();
    final longestMealStreak = await getLongestMealStreak();

    return {
      'waterStreak': waterStreak,
      'mealStreak': mealStreak,
      'longestWaterStreak': longestWaterStreak,
      'longestMealStreak': longestMealStreak,
      'overallStreak': waterStreak > mealStreak ? mealStreak : waterStreak, // Minimum of both
    };
  }
}

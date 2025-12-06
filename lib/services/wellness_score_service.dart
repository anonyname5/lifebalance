import '../data/repositories/water_repository.dart';
import '../data/repositories/meal_repository.dart';
import '../core/utils/date_helper.dart';
import '../services/preferences_service.dart';

/// Service for calculating wellness scores
class WellnessScoreService {
  final WaterRepository _waterRepository = WaterRepository();
  final MealRepository _mealRepository = MealRepository();

  /// Calculate daily wellness score (0-100)
  Future<double> calculateDailyScore(DateTime date) async {
    final dateString = DateHelper.formatDateForDb(date);
    
    // Water score (50 points max)
    final waterGoal = await PreferencesService.getWaterGoal();
    final totalGlasses = await _waterRepository.getTotalGlassesByDate(dateString);
    final waterScore = (totalGlasses / waterGoal * 50).clamp(0.0, 50.0);

    // Meal score (50 points max)
    final mealLogs = await _mealRepository.getMealLogsByDate(dateString);
    final mealCount = mealLogs.length;
    // Ideal: 3 meals per day
    final mealScore = (mealCount / 3 * 50).clamp(0.0, 50.0);

    return waterScore + mealScore;
  }

  /// Calculate weekly wellness score
  Future<Map<String, dynamic>> calculateWeeklyScore() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    double totalScore = 0.0;
    int daysWithData = 0;
    final Map<String, double> dailyScores = {};

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final score = await calculateDailyScore(date);
      
      if (score > 0) {
        daysWithData++;
        totalScore += score;
      }
      
      dailyScores[DateHelper.formatDate(date)] = score;
    }

    final averageScore = daysWithData > 0 ? totalScore / daysWithData : 0.0;

    return {
      'averageScore': averageScore,
      'totalScore': totalScore,
      'daysWithData': daysWithData,
      'dailyScores': dailyScores,
    };
  }

  /// Calculate monthly wellness score
  Future<Map<String, dynamic>> calculateMonthlyScore() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    
    double totalScore = 0.0;
    int daysWithData = 0;
    final Map<String, double> dailyScores = {};

    for (int i = 0; i <= monthEnd.difference(monthStart).inDays; i++) {
      final date = monthStart.add(Duration(days: i));
      final score = await calculateDailyScore(date);
      
      if (score > 0) {
        daysWithData++;
        totalScore += score;
      }
      
      dailyScores[DateHelper.formatDate(date)] = score;
    }

    final averageScore = daysWithData > 0 ? totalScore / daysWithData : 0.0;

    return {
      'averageScore': averageScore,
      'totalScore': totalScore,
      'daysWithData': daysWithData,
      'totalDays': monthEnd.difference(monthStart).inDays + 1,
      'dailyScores': dailyScores,
    };
  }

  /// Get wellness grade (A, B, C, D, F)
  String getWellnessGrade(double score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  /// Get wellness status message
  String getWellnessStatus(double score) {
    if (score >= 90) return 'Excellent! Keep it up!';
    if (score >= 80) return 'Great job! You\'re doing well.';
    if (score >= 70) return 'Good progress! Keep going.';
    if (score >= 60) return 'Not bad, but you can do better!';
    return 'Let\'s work on improving your wellness habits.';
  }
}

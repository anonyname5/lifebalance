import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/achievement.dart';
import '../data/repositories/water_repository.dart';
import '../data/repositories/meal_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../data/repositories/savings_repository.dart';
import '../services/streak_service.dart';
import '../services/wellness_score_service.dart';
import '../core/utils/date_helper.dart';

/// Service for managing achievements
class AchievementService {
  final WaterRepository _waterRepository = WaterRepository();
  final MealRepository _mealRepository = MealRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final SavingsRepository _savingsRepository = SavingsRepository();
  final StreakService _streakService = StreakService();
  final WellnessScoreService _wellnessScoreService = WellnessScoreService();

  static const String _keyPrefix = 'achievement_';

  /// Get all predefined achievements
  List<Achievement> getAllAchievements() {
    return [
      // Water achievements
      Achievement(
        id: 'water_1',
        title: 'First Drop',
        description: 'Log your first glass of water',
        icon: '💧',
        type: AchievementType.water,
        targetValue: 1,
        isUnlocked: _isUnlocked('water_1'),
      ),
      Achievement(
        id: 'water_10',
        title: 'Hydration Hero',
        description: 'Log 10 glasses of water in a day',
        icon: '🚰',
        type: AchievementType.water,
        targetValue: 10,
        isUnlocked: _isUnlocked('water_10'),
      ),
      Achievement(
        id: 'water_100',
        title: 'Water Master',
        description: 'Log 100 total glasses of water',
        icon: '🌊',
        type: AchievementType.water,
        targetValue: 100,
        isUnlocked: _isUnlocked('water_100'),
      ),

      // Meal achievements
      Achievement(
        id: 'meal_1',
        title: 'First Bite',
        description: 'Log your first meal',
        icon: '🍽️',
        type: AchievementType.meal,
        targetValue: 1,
        isUnlocked: _isUnlocked('meal_1'),
      ),
      Achievement(
        id: 'meal_50',
        title: 'Meal Logger',
        description: 'Log 50 meals',
        icon: '🍴',
        type: AchievementType.meal,
        targetValue: 50,
        isUnlocked: _isUnlocked('meal_50'),
      ),
      Achievement(
        id: 'meal_100',
        title: 'Food Tracker',
        description: 'Log 100 meals',
        icon: '🥘',
        type: AchievementType.meal,
        targetValue: 100,
        isUnlocked: _isUnlocked('meal_100'),
      ),

      // Streak achievements
      Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        icon: '🔥',
        type: AchievementType.streak,
        targetValue: 7,
        isUnlocked: _isUnlocked('streak_7'),
      ),
      Achievement(
        id: 'streak_30',
        title: 'Monthly Champion',
        description: 'Maintain a 30-day streak',
        icon: '⭐',
        type: AchievementType.streak,
        targetValue: 30,
        isUnlocked: _isUnlocked('streak_30'),
      ),

      // Expense achievements
      Achievement(
        id: 'expense_10',
        title: 'Spender',
        description: 'Log 10 expenses',
        icon: '💰',
        type: AchievementType.expense,
        targetValue: 10,
        isUnlocked: _isUnlocked('expense_10'),
      ),
      Achievement(
        id: 'expense_100',
        title: 'Expense Expert',
        description: 'Log 100 expenses',
        icon: '💵',
        type: AchievementType.expense,
        targetValue: 100,
        isUnlocked: _isUnlocked('expense_100'),
      ),

      // Savings achievements
      Achievement(
        id: 'savings_goal_1',
        title: 'Goal Setter',
        description: 'Create your first savings goal',
        icon: '🎯',
        type: AchievementType.savings,
        targetValue: 1,
        isUnlocked: _isUnlocked('savings_goal_1'),
      ),
      Achievement(
        id: 'savings_complete',
        title: 'Goal Achiever',
        description: 'Complete a savings goal',
        icon: '🏆',
        type: AchievementType.savings,
        targetValue: 1,
        isUnlocked: _isUnlocked('savings_complete'),
      ),

      // Wellness achievements
      Achievement(
        id: 'wellness_90',
        title: 'Wellness Master',
        description: 'Achieve a 90+ wellness score',
        icon: '🌟',
        type: AchievementType.wellness,
        targetValue: 90,
        isUnlocked: _isUnlocked('wellness_90'),
      ),
    ];
  }

  /// Check if achievement is unlocked
  bool _isUnlocked(String id) {
    // This would typically check SharedPreferences
    // For now, we'll implement async version
    return false;
  }

  /// Check and unlock achievements (async version)
  Future<List<Achievement>> checkAndUnlockAchievements() async {
    final achievements = getAllAchievements();
    final unlockedAchievements = <Achievement>[];

    for (var achievement in achievements) {
      if (achievement.isUnlocked) continue;

      bool shouldUnlock = false;

      switch (achievement.type) {
        case AchievementType.water:
          shouldUnlock = await _checkWaterAchievement(achievement);
          break;
        case AchievementType.meal:
          shouldUnlock = await _checkMealAchievement(achievement);
          break;
        case AchievementType.streak:
          shouldUnlock = await _checkStreakAchievement(achievement);
          break;
        case AchievementType.expense:
          shouldUnlock = await _checkExpenseAchievement(achievement);
          break;
        case AchievementType.savings:
          shouldUnlock = await _checkSavingsAchievement(achievement);
          break;
        case AchievementType.wellness:
          shouldUnlock = await _checkWellnessAchievement(achievement);
          break;
        default:
          break;
      }

      if (shouldUnlock) {
        await _unlockAchievement(achievement.id);
        unlockedAchievements.add(
          achievement.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
          ),
        );
      }
    }

    return unlockedAchievements;
  }

  Future<bool> _checkWaterAchievement(Achievement achievement) async {
    if (achievement.id == 'water_1') {
      final today = DateHelper.todayAsString();
      final total = await _waterRepository.getTotalGlassesByDate(today);
      return total >= 1;
    } else if (achievement.id == 'water_10') {
      final today = DateHelper.todayAsString();
      final total = await _waterRepository.getTotalGlassesByDate(today);
      return total >= 10;
    } else if (achievement.id == 'water_100') {
      final allLogs = await _waterRepository.getWaterLogsByDateRange(
        DateHelper.formatDateForDb(DateTime.now().subtract(const Duration(days: 365))),
        DateHelper.formatDateForDb(DateTime.now()),
      );
      final total = allLogs.fold(0, (sum, log) => sum + log.glasses);
      return total >= 100;
    }
    return false;
  }

  Future<bool> _checkMealAchievement(Achievement achievement) async {
    final allLogs = await _mealRepository.getMealLogsByDateRange(
      DateHelper.formatDateForDb(DateTime.now().subtract(const Duration(days: 365))),
      DateHelper.formatDateForDb(DateTime.now()),
    );
    final count = allLogs.length;

    if (achievement.id == 'meal_1') {
      return count >= 1;
    } else if (achievement.id == 'meal_50') {
      return count >= 50;
    } else if (achievement.id == 'meal_100') {
      return count >= 100;
    }
    return false;
  }

  Future<bool> _checkStreakAchievement(Achievement achievement) async {
    final overallStreak = await _streakService.getOverallStreak();
    final streak = overallStreak['overallStreak'] as int;

    if (achievement.id == 'streak_7') {
      return streak >= 7;
    } else if (achievement.id == 'streak_30') {
      return streak >= 30;
    }
    return false;
  }

  Future<bool> _checkExpenseAchievement(Achievement achievement) async {
    final allExpenses = await _expenseRepository.getExpensesByDateRange(
      DateHelper.formatDateForDb(DateTime.now().subtract(const Duration(days: 365))),
      DateHelper.formatDateForDb(DateTime.now()),
    );
    final count = allExpenses.length;

    if (achievement.id == 'expense_10') {
      return count >= 10;
    } else if (achievement.id == 'expense_100') {
      return count >= 100;
    }
    return false;
  }

  Future<bool> _checkSavingsAchievement(Achievement achievement) async {
    if (achievement.id == 'savings_goal_1') {
      final goals = await _savingsRepository.getAllSavingsGoals();
      return goals.isNotEmpty;
    } else if (achievement.id == 'savings_complete') {
      final goals = await _savingsRepository.getAllSavingsGoals();
      return goals.any((goal) => goal.isCompleted == 1);
    }
    return false;
  }

  Future<bool> _checkWellnessAchievement(Achievement achievement) async {
    if (achievement.id == 'wellness_90') {
      final weeklyScore = await _wellnessScoreService.calculateWeeklyScore();
      final averageScore = weeklyScore['averageScore'] as double;
      return averageScore >= 90;
    }
    return false;
  }

  /// Unlock an achievement
  Future<void> _unlockAchievement(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyPrefix$id', true);
    await prefs.setString('${_keyPrefix}${id}_unlocked_at', DateTime.now().toIso8601String());
  }

  /// Get unlocked achievements
  Future<List<String>> getUnlockedAchievementIds() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    return allKeys
        .where((key) => key.startsWith(_keyPrefix) && !key.contains('_unlocked_at'))
        .where((key) => prefs.getBool(key) == true)
        .map((key) => key.replaceFirst(_keyPrefix, ''))
        .toList();
  }

  /// Load achievement unlock status
  Future<List<Achievement>> loadAchievementsWithStatus() async {
    final achievements = getAllAchievements();
    final unlockedIds = await getUnlockedAchievementIds();
    final prefs = await SharedPreferences.getInstance();

    return achievements.map((achievement) {
      final isUnlocked = unlockedIds.contains(achievement.id);
      final unlockedAtStr = prefs.getString('${_keyPrefix}${achievement.id}_unlocked_at');
      
      return achievement.copyWith(
        isUnlocked: isUnlocked,
        unlockedAt: unlockedAtStr != null ? DateTime.parse(unlockedAtStr) : null,
      );
    }).toList();
  }
}

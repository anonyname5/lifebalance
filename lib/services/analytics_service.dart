import '../data/repositories/expense_repository.dart';
import '../data/repositories/water_repository.dart';
import '../data/repositories/meal_repository.dart';
import '../core/utils/date_helper.dart';

/// Service for advanced analytics, trends, and predictions
class AnalyticsService {
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final WaterRepository _waterRepository = WaterRepository();
  final MealRepository _mealRepository = MealRepository();

  /// Get spending trend for the last N months
  Future<Map<String, dynamic>> getSpendingTrend({int months = 6}) async {
    final now = DateTime.now();
    final trends = <String, double>{};

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);

      final expenses = await _expenseRepository.getExpensesByDateRange(
        DateHelper.formatDateForDb(firstDay),
        DateHelper.formatDateForDb(lastDay),
      );

      final total = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
      final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      trends[monthKey] = total;
    }

    // Calculate average
    final average = trends.values.fold(0.0, (sum, value) => sum + value) / trends.length;

    // Calculate trend direction
    final values = trends.values.toList();
    final recent = values.length >= 2 ? values[values.length - 1] : 0.0;
    final previous = values.length >= 2 ? values[values.length - 2] : 0.0;
    final trendDirection = recent > previous ? 'increasing' : recent < previous ? 'decreasing' : 'stable';
    final trendPercentage = previous > 0 ? ((recent - previous) / previous * 100) : 0.0;

    return {
      'trends': trends,
      'average': average,
      'current': recent,
      'previous': previous,
      'trendDirection': trendDirection,
      'trendPercentage': trendPercentage,
    };
  }

  /// Get water intake trend for the last N days
  Future<Map<String, dynamic>> getWaterTrend({int days = 30}) async {
    final now = DateTime.now();
    final trends = <String, int>{};

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateString = DateHelper.formatDateForDb(date);
      final total = await _waterRepository.getTotalGlassesByDate(dateString);
      trends[dateString] = total;
    }

    // Calculate average
    final average = trends.values.fold(0, (sum, value) => sum + value) / trends.length;

    // Calculate weekly averages
    final weeklyAverages = <String, double>{};
    for (int week = 0; week < (days / 7).ceil(); week++) {
      final weekStart = now.subtract(Duration(days: days - (week * 7)));
      final weekEnd = weekStart.add(const Duration(days: 6));
      double weekTotal = 0.0;
      int weekDays = 0;

      for (int i = 0; i < 7 && weekStart.add(Duration(days: i)).isBefore(now); i++) {
        final date = weekStart.add(Duration(days: i));
        final dateString = DateHelper.formatDateForDb(date);
        weekTotal += trends[dateString]?.toDouble() ?? 0.0;
        weekDays++;
      }

      if (weekDays > 0) {
        weeklyAverages['Week ${week + 1}'] = weekTotal / weekDays;
      }
    }

    return {
      'dailyTrends': trends,
      'average': average,
      'weeklyAverages': weeklyAverages,
    };
  }

  /// Predict monthly spending based on current spending rate
  Future<Map<String, dynamic>> predictMonthlySpending() async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysPassed = now.day;
    final daysRemaining = daysInMonth - daysPassed;

    // Get current month spending
    final expenses = await _expenseRepository.getExpensesByDateRange(
      DateHelper.formatDateForDb(firstDay),
      DateHelper.formatDateForDb(now),
    );

    final currentSpending = expenses.fold(0.0, (sum, expense) => sum + expense.amount);

    // Calculate daily average
    final dailyAverage = daysPassed > 0 ? currentSpending / daysPassed : 0.0;

    // Predict total for the month
    final predictedTotal = currentSpending + (dailyAverage * daysRemaining);

    // Get last month for comparison
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);
    final lastMonthExpenses = await _expenseRepository.getExpensesByDateRange(
      DateHelper.formatDateForDb(lastMonth),
      DateHelper.formatDateForDb(lastMonthEnd),
    );
    final lastMonthTotal = lastMonthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

    // Calculate difference
    final difference = predictedTotal - lastMonthTotal;
    final differencePercentage = lastMonthTotal > 0 ? (difference / lastMonthTotal * 100) : 0.0;

    return {
      'currentSpending': currentSpending,
      'predictedTotal': predictedTotal,
      'lastMonthTotal': lastMonthTotal,
      'dailyAverage': dailyAverage,
      'daysPassed': daysPassed,
      'daysRemaining': daysRemaining,
      'difference': difference,
      'differencePercentage': differencePercentage,
      'trend': difference > 0 ? 'increasing' : difference < 0 ? 'decreasing' : 'stable',
    };
  }

  /// Get category spending comparison (this month vs last month)
  Future<Map<String, Map<String, double>>> getCategoryComparison() async {
    final now = DateTime.now();

    // This month
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final thisMonthEnd = DateTime(now.year, now.month + 1, 0);
    final thisMonthExpenses = await _expenseRepository.getExpensesByDateRange(
      DateHelper.formatDateForDb(thisMonthStart),
      DateHelper.formatDateForDb(thisMonthEnd),
    );

    // Last month
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);
    final lastMonthExpenses = await _expenseRepository.getExpensesByDateRange(
      DateHelper.formatDateForDb(lastMonthStart),
      DateHelper.formatDateForDb(lastMonthEnd),
    );

    // Calculate totals by category
    final thisMonthByCategory = <String, double>{};
    final lastMonthByCategory = <String, double>{};

    for (var expense in thisMonthExpenses) {
      thisMonthByCategory[expense.category] =
          (thisMonthByCategory[expense.category] ?? 0.0) + expense.amount;
    }

    for (var expense in lastMonthExpenses) {
      lastMonthByCategory[expense.category] =
          (lastMonthByCategory[expense.category] ?? 0.0) + expense.amount;
    }

    // Combine all categories
    final allCategories = <String>{};
    allCategories.addAll(thisMonthByCategory.keys);
    allCategories.addAll(lastMonthByCategory.keys);

    final comparison = <String, Map<String, double>>{};
    for (var category in allCategories) {
      final thisMonth = thisMonthByCategory[category] ?? 0.0;
      final lastMonth = lastMonthByCategory[category] ?? 0.0;
      final change = thisMonth - lastMonth;
      final changePercentage = lastMonth > 0 ? (change / lastMonth * 100) : 0.0;

      comparison[category] = {
        'thisMonth': thisMonth,
        'lastMonth': lastMonth,
        'change': change,
        'changePercentage': changePercentage,
      };
    }

    return comparison;
  }

  /// Get meal logging frequency trend
  Future<Map<String, dynamic>> getMealFrequencyTrend({int days = 30}) async {
    final now = DateTime.now();
    final trends = <String, int>{};

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateString = DateHelper.formatDateForDb(date);
      final meals = await _mealRepository.getMealLogsByDate(dateString);
      trends[dateString] = meals.length;
    }

    // Calculate average meals per day
    final average = trends.values.fold(0, (sum, value) => sum + value) / trends.length;

    // Count days with 0, 1, 2, 3+ meals
    final mealFrequency = {
      '0': 0,
      '1': 0,
      '2': 0,
      '3+': 0,
    };

    for (var count in trends.values) {
      if (count == 0) {
        mealFrequency['0'] = mealFrequency['0']! + 1;
      } else if (count == 1) {
        mealFrequency['1'] = mealFrequency['1']! + 1;
      } else if (count == 2) {
        mealFrequency['2'] = mealFrequency['2']! + 1;
      } else {
        mealFrequency['3+'] = mealFrequency['3+']! + 1;
      }
    }

    return {
      'dailyTrends': trends,
      'average': average,
      'mealFrequency': mealFrequency,
    };
  }

  /// Get insights and recommendations
  Future<List<Map<String, dynamic>>> getInsights() async {
    final insights = <Map<String, dynamic>>[];

    // Spending prediction insight
    final spendingPrediction = await predictMonthlySpending();
    if (spendingPrediction['trend'] == 'increasing') {
      insights.add({
        'type': 'warning',
        'title': 'Spending Alert',
        'message':
            'Your spending is ${spendingPrediction['differencePercentage'].toStringAsFixed(1)}% higher than last month. Consider reviewing your expenses.',
        'icon': '💰',
      });
    }

    // Water intake insight
    final waterTrend = await getWaterTrend(days: 7);
    final weeklyAverage = waterTrend['average'] as double;
    if (weeklyAverage < 6) {
      insights.add({
        'type': 'info',
        'title': 'Hydration Reminder',
        'message':
            'Your average water intake is ${weeklyAverage.toStringAsFixed(1)} glasses per day. Aim for 8 glasses daily!',
        'icon': '💧',
      });
    }

    // Meal logging insight
    final mealTrend = await getMealFrequencyTrend(days: 7);
    final avgMeals = mealTrend['average'] as double;
    if (avgMeals < 2) {
      insights.add({
        'type': 'info',
        'title': 'Meal Tracking',
        'message':
            'You\'re logging ${avgMeals.toStringAsFixed(1)} meals per day on average. Try to log all your meals for better tracking!',
        'icon': '🍽️',
      });
    }

    return insights;
  }
}

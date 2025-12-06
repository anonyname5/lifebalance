import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_helper.dart';
import '../../finance/providers/expense_provider.dart';
import '../providers/streak_provider.dart';
import '../providers/wellness_score_provider.dart';
import '../providers/analytics_provider.dart';
import 'achievements_screen.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/water_repository.dart';
import '../../../services/wellness_score_service.dart';

final waterRepositoryProvider = Provider<WaterRepository>((ref) {
  return WaterRepository();
});

/// Insights screen with charts and analytics
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.insights),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.water_drop), text: 'Wellness'),
              Tab(icon: Icon(Icons.account_balance_wallet), text: 'Finance'),
              Tab(icon: Icon(Icons.emoji_events), text: 'Achievements'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            WellnessInsightsTab(),
            FinanceInsightsTab(),
            AchievementsScreen(),
          ],
        ),
      ),
    );
  }
}

/// Wellness insights tab
class WellnessInsightsTab extends ConsumerWidget {
  const WellnessInsightsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterRepository = ref.watch(waterRepositoryProvider);
    final overallStreakAsync = ref.watch(overallStreakProvider);
    final weeklyScoreAsync = ref.watch(weeklyWellnessScoreProvider);
    final monthlyScoreAsync = ref.watch(monthlyWellnessScoreProvider);
    
    return FutureBuilder(
      future: _getWeeklyWaterData(waterRepository),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final weeklyData = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Streak Cards
              overallStreakAsync.when(
                data: (streakData) => _buildStreakCards(context, streakData),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // Wellness Scores
              weeklyScoreAsync.when(
                data: (weeklyData) => _buildWellnessScoreCard(
                  context,
                  'Weekly Score',
                  weeklyData['averageScore'] as double,
                  weeklyData['daysWithData'] as int,
                  7,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              monthlyScoreAsync.when(
                data: (monthlyData) => _buildWellnessScoreCard(
                  context,
                  'Monthly Score',
                  monthlyData['averageScore'] as double,
                  monthlyData['daysWithData'] as int,
                  monthlyData['totalDays'] as int,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              Text(
                'Water Intake - Last 7 Days',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 12,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: AppColors.primary,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < weeklyData.length) {
                              final date = weeklyData[value.toInt()]['date'] as String;
                              final day = date.split('-')[2];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(day),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(value.toInt().toString());
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: weeklyData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      final glasses = data['glasses'] as int;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: glasses.toDouble(),
                            color: AppColors.primary,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getWeeklyWaterData(
    WaterRepository repository,
  ) async {
    final now = DateTime.now();
    final List<Map<String, dynamic>> data = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateString = DateHelper.formatDateForDb(date);
      final total = await repository.getTotalGlassesByDate(dateString);
      data.add({
        'date': dateString,
        'glasses': total,
      });
    }

    return data;
  }

  Widget _buildStreakCards(BuildContext context, Map<String, dynamic> streakData) {
    final waterStreak = streakData['waterStreak'] as int;
    final mealStreak = streakData['mealStreak'] as int;
    final longestWaterStreak = streakData['longestWaterStreak'] as int;
    final longestMealStreak = streakData['longestMealStreak'] as int;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                color: AppColors.primary.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.water_drop, size: 32, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text(
                        '$waterStreak',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                      Text(
                        'Day Water Streak',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      if (longestWaterStreak > waterStreak)
                        Text(
                          'Best: $longestWaterStreak days',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                color: AppColors.accent.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.restaurant, size: 32, color: AppColors.accent),
                      const SizedBox(height: 8),
                      Text(
                        '$mealStreak',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                      ),
                      Text(
                        'Day Meal Streak',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      if (longestMealStreak > mealStreak)
                        Text(
                          'Best: $longestMealStreak days',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWellnessScoreCard(
    BuildContext context,
    String title,
    double score,
    int daysWithData,
    int totalDays,
  ) {
    final wellnessService = WellnessScoreService();
    final grade = wellnessService.getWellnessGrade(score);
    final status = wellnessService.getWellnessStatus(score);

    Color scoreColor;
    if (score >= 90) {
      scoreColor = AppColors.success;
    } else if (score >= 70) {
      scoreColor = AppColors.info;
    } else if (score >= 60) {
      scoreColor = AppColors.warning;
    } else {
      scoreColor = AppColors.error;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    grade,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        score.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scoreColor,
                            ),
                      ),
                      Text(
                        'out of 100',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$daysWithData / $totalDays days',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        status,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }
}

/// Finance insights tab
class FinanceInsightsTab extends ConsumerWidget {
  const FinanceInsightsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseRepository = ref.watch(expenseRepositoryProvider);
    final currentMonthTotalAsync = ref.watch(currentMonthTotalProvider);
    final spendingPredictionAsync = ref.watch(monthlySpendingPredictionProvider);
    final spendingTrendAsync = ref.watch(spendingTrendProvider);
    final categoryComparisonAsync = ref.watch(categoryComparisonProvider);
    final insightsAsync = ref.watch(insightsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Insights Cards
          insightsAsync.when(
            data: (insights) {
              if (insights.isEmpty) return const SizedBox.shrink();
              return Column(
                children: [
                  ...insights.map((insight) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: insight['type'] == 'warning'
                            ? AppColors.warning.withOpacity(0.1)
                            : AppColors.info.withOpacity(0.1),
                        child: ListTile(
                          leading: Text(
                            insight['icon'] as String,
                            style: const TextStyle(fontSize: 32),
                          ),
                          title: Text(
                            insight['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(insight['message'] as String),
                        ),
                      )),
                  const SizedBox(height: 16),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Monthly Total Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'This Month\'s Spending',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  currentMonthTotalAsync.when(
                    data: (total) => Text(
                      'RM${total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Spending Prediction Card
          spendingPredictionAsync.when(
            data: (prediction) => Card(
              color: AppColors.info.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.trending_up, color: AppColors.info),
                        const SizedBox(width: 8),
                        Text(
                          'Monthly Prediction',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Predicted Total: RM${prediction['predictedTotal'].toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current: RM${prediction['currentSpending'].toStringAsFixed(2)} (${prediction['daysPassed']} days)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Last Month: RM${prediction['lastMonthTotal'].toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (prediction['differencePercentage'] != 0.0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (prediction['trend'] == 'increasing'
                                  ? AppColors.warning
                                  : AppColors.success)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              prediction['trend'] == 'increasing'
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: prediction['trend'] == 'increasing'
                                  ? AppColors.warning
                                  : AppColors.success,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${prediction['differencePercentage'].toStringAsFixed(1)}% ${prediction['trend'] == 'increasing' ? 'more' : 'less'} than last month',
                              style: TextStyle(
                                color: prediction['trend'] == 'increasing'
                                    ? AppColors.warning
                                    : AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          // Spending Trend Chart
          Text(
            'Spending Trend (Last 6 Months)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          spendingTrendAsync.when(
            data: (trend) => _buildSpendingTrendChart(context, trend),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          // Category Comparison
          Text(
            'Category Comparison (This Month vs Last Month)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          categoryComparisonAsync.when(
            data: (comparison) => _buildCategoryComparison(context, comparison),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          // Spending by Category
          Text(
            'Spending by Category',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          FutureBuilder(
            future: _getCategorySpending(expenseRepository),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final categoryData = snapshot.data ?? {};

              if (categoryData.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No spending data this month',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ),
                );
              }

              final total = categoryData.values
                  .fold(0.0, (sum, amount) => sum + amount);

              return SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    sections: categoryData.entries.map((entry) {
                      final percentage = entry.value / total * 100;
                      return PieChartSectionData(
                        value: entry.value,
                        title: '${percentage.toStringAsFixed(1)}%',
                        color: _getCategoryColor(entry.key),
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Category List
          FutureBuilder(
            future: _getCategorySpending(expenseRepository),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final categoryData = snapshot.data ?? {};
              final sortedCategories = categoryData.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              return Column(
                children: sortedCategories.map((entry) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getCategoryColor(entry.key).withOpacity(0.2),
                        child: Icon(
                          _getCategoryIcon(entry.key),
                          color: _getCategoryColor(entry.key),
                        ),
                      ),
                      title: Text(entry.key),
                      trailing: Text(
                        'RM${entry.value.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<Map<String, double>> _getCategorySpending(
    ExpenseRepository repository,
  ) async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    return await repository.getExpensesByCategory(
      DateHelper.formatDateForDb(firstDay),
      DateHelper.formatDateForDb(lastDay),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Food': Colors.orange,
      'Transport': Colors.blue,
      'Shopping': Colors.purple,
      'Entertainment': Colors.pink,
      'Bills': Colors.red,
      'Health': Colors.green,
      'Education': Colors.teal,
      'Other': Colors.grey,
    };
    return colors[category] ?? Colors.grey;
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Food': Icons.restaurant,
      'Transport': Icons.directions_car,
      'Shopping': Icons.shopping_bag,
      'Entertainment': Icons.movie,
      'Bills': Icons.receipt,
      'Health': Icons.medical_services,
      'Education': Icons.school,
      'Other': Icons.category,
    };
    return icons[category] ?? Icons.category;
  }

  Widget _buildSpendingTrendChart(BuildContext context, Map<String, dynamic> trend) {
    final trends = trend['trends'] as Map<String, double>;
    final entries = trends.entries.toList();
    
    if (entries.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final maxValue = trends.values.reduce((a, b) => a > b ? a : b);
    final minValue = trends.values.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;
    final chartMax = maxValue + (range * 0.2);

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text('RM${value.toInt()}');
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < entries.length) {
                    final monthKey = entries[value.toInt()].key;
                    final parts = monthKey.split('-');
                    return Text('${parts[1]}/${parts[0].substring(2)}');
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: (entries.length - 1).toDouble(),
          minY: 0,
          maxY: chartMax,
          lineBarsData: [
            LineChartBarData(
              spots: entries.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.value);
              }).toList(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryComparison(
    BuildContext context,
    Map<String, Map<String, double>> comparison,
  ) {
    final sortedCategories = comparison.entries.toList()
      ..sort((a, b) => b.value['thisMonth']!.compareTo(a.value['thisMonth']!));

    return Column(
      children: sortedCategories.map((entry) {
        final category = entry.key;
        final data = entry.value;
        final thisMonth = data['thisMonth']!;
        final lastMonth = data['lastMonth']!;
        final change = data['change']!;
        final changePercentage = data['changePercentage']!;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(_getCategoryIcon(category), color: _getCategoryColor(category)),
                        const SizedBox(width: 8),
                        Text(
                          category,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    Text(
                      'RM${thisMonth.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Last month: RM${lastMonth.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    if (change != 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (change > 0 ? AppColors.warning : AppColors.success)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              change > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 16,
                              color: change > 0 ? AppColors.warning : AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${changePercentage.abs().toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: change > 0 ? AppColors.warning : AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

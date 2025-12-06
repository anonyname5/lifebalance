import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/currency_helper.dart';
import '../../settings/providers/currency_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/widgets/gradient_card.dart';
import '../../wellness/screens/wellness_screen.dart';
import '../../wellness/screens/meal_logging_screen.dart';
import '../../wellness/providers/water_provider.dart';
import '../../wellness/providers/meal_provider.dart';
import '../../finance/screens/finance_screen.dart';
import '../../finance/providers/expense_provider.dart';
import '../../insights/screens/insights_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../settings/screens/notifications_screen.dart';
import '../../../services/preferences_service.dart';

/// Home/Dashboard screen - Main entry point with bottom navigation
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.appName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              DateHelper.formatFullDate(DateTime.now()),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 20,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.textPrimary,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                PageTransitions.slideRoute(
                  const NotificationsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.settings_outlined,
                size: 20,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.textPrimary,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                PageTransitions.slideRoute(
                  const SettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.5)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFFB0B0B0)
              : AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
            label: AppStrings.home,
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.water_drop_outlined),
              activeIcon: Icon(Icons.water_drop),
            label: AppStrings.wellness,
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
            label: AppStrings.finance,
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.insights_outlined),
              activeIcon: Icon(Icons.insights),
            label: AppStrings.insights,
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _getCurrentScreen(),
    );
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard(key: const ValueKey('dashboard'));
      case 1:
        return _buildWellnessPlaceholder(key: const ValueKey('wellness'));
      case 2:
        return _buildFinancePlaceholder(key: const ValueKey('finance'));
      case 3:
        return _buildInsightsPlaceholder(key: const ValueKey('insights'));
      default:
        return _buildDashboard(key: const ValueKey('dashboard'));
    }
  }

  Widget _buildDashboard({Key? key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Greeting
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildGreeting(),
          ),
          const SizedBox(height: 24),
          
          // Water Card
          _buildWaterCard(),
          
          // Meals Card
          _buildMealsCard(),
          
          // Finance Card
          _buildFinanceCard(),
        ],
      ),
    );
  }

  Widget _buildWellnessPlaceholder({Key? key}) {
    return WellnessScreen(key: key);
  }

  Widget _buildFinancePlaceholder({Key? key}) {
    return FinanceScreen(key: key);
  }

  Widget _buildInsightsPlaceholder({Key? key}) {
    return InsightsScreen(key: key);
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;
    if (hour < 12) {
      greeting = 'Good Morning';
      emoji = '☀️';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      emoji = '🌤️';
    } else {
      greeting = 'Good Evening';
      emoji = '🌙';
    }

    return Row(
      children: [
        Text(
      greeting,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
        ),
        const SizedBox(width: 8),
        Text(
          emoji,
          style: const TextStyle(fontSize: 28),
        ),
      ],
    );
  }

  Widget _buildWaterCard() {
    final totalGlassesAsync = ref.watch(todayTotalGlassesProvider);

    return GradientCard(
      gradient: AppColors.waterGradient,
        onTap: () {
          setState(() {
            _currentIndex = 1; // Navigate to wellness tab
          });
        },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                onPressed: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                },
                  ),
                ],
              ),
          const SizedBox(height: 16),
          Text(
            'Water Today',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
              const SizedBox(height: 12),
              FutureBuilder<int>(
                future: PreferencesService.getWaterGoal(),
                builder: (context, goalSnapshot) {
                  final waterGoal = goalSnapshot.data ?? 8;
                  return totalGlassesAsync.when(
                    data: (total) {
                      final progress = total / waterGoal;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                            value: progress > 1.0 ? 1.0 : progress,
                          minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$total / $waterGoal ${AppStrings.glasses}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                          ),
                        ],
                      );
                    },
                loading: () => const LinearProgressIndicator(
                  backgroundColor: Colors.white30,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                error: (error, stack) => Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.white),
                ),
                  );
                },
              ),
            ],
      ),
    );
  }

  Widget _buildMealsCard() {
    final today = DateHelper.todayAsString();
    final mealLogsAsync = ref.watch(mealNotifierProvider(today));

    return GradientCard(
      gradient: AppColors.mealGradient,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransitions.slideRoute(
                      const MealLoggingScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text(
                  AppStrings.logMeal,
                  style: TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Text(
            AppStrings.mealsLogged,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
            const SizedBox(height: 12),
            mealLogsAsync.when(
              data: (meals) {
                if (meals.isEmpty) {
                  return Text(
                    'No meals logged today',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: meals.take(3).map((meal) {
                    return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                      child: Text(
                        '${meal.mealType}: ${DateHelper.formatTime(DateHelper.parseTimeFromDb(meal.time))}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                      ),
                    );
                  }).toList(),
                );
              },
            loading: () => const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            error: (error, stack) => Text(
              'Error: $error',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceCard() {
    final totalExpensesAsync = ref.watch(todayTotalExpensesProvider);
    final currency = ref.watch(currencyProvider);

    return GradientCard(
      gradient: AppColors.financeGradient,
        onTap: () {
          setState(() {
            _currentIndex = 2; // Navigate to finance tab
          });
        },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                onPressed: () {
                  setState(() {
                    _currentIndex = 2;
                  });
                },
                  ),
                ],
              ),
          const SizedBox(height: 16),
          Text(
            AppStrings.todaySpending,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
              const SizedBox(height: 12),
              totalExpensesAsync.when(
                data: (total) => Text(
              CurrencyHelper.formatAmount(total, currency),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 32,
                      ),
                ),
            loading: () => const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            error: (error, stack) => Text(
              'Error: $error',
              style: const TextStyle(color: Colors.white),
            ),
              ),
          const SizedBox(height: 16),
          TextButton.icon(
                onPressed: () {
                  setState(() {
                    _currentIndex = 2; // Navigate to finance tab
                  });
                },
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: const Text(
              AppStrings.addExpense,
              style: TextStyle(color: Colors.white),
              ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
          ),
        ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/animated_progress_indicator.dart';
import '../../../core/widgets/animated_value.dart';
import '../providers/water_provider.dart';
import '../widgets/water_filter_widget.dart';
import '../../../data/models/water_log.dart';
import '../../../services/achievement_service.dart';
import '../../insights/providers/achievement_provider.dart';
import '../../../services/preferences_service.dart';

/// Water tracking screen
class WaterTrackingScreen extends ConsumerStatefulWidget {
  const WaterTrackingScreen({super.key});

  @override
  ConsumerState<WaterTrackingScreen> createState() =>
      _WaterTrackingScreenState();
}

class _WaterTrackingScreenState extends ConsumerState<WaterTrackingScreen> {
  int _waterGoal = 8;

  @override
  void initState() {
    super.initState();
    _loadWaterGoal();
  }

  Future<void> _loadWaterGoal() async {
    final goal = await PreferencesService.getWaterGoal();
    setState(() {
      _waterGoal = goal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateHelper.todayAsString();
    final filter = ref.watch(waterFilterProvider);
    final waterLogsAsync = filter.hasActiveFilters
        ? ref.watch(filteredWaterLogsProvider)
        : ref.watch(waterNotifierProvider(today));
    final totalGlassesAsync = ref.watch(todayTotalGlassesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.waterIntake),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (filter.hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => const WaterFilterWidget(),
              );
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Goal Header
            Center(
              child: Text(
              '${AppStrings.dailyGoal}: $_waterGoal ${AppStrings.glasses}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 32),

            // Progress Circle
            Center(
              child: totalGlassesAsync.when(
                data: (total) => _buildProgressCircle(total),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
            ),
            const SizedBox(height: 32),

            // Quick Add Buttons
            _buildQuickAddButtons(),
            const SizedBox(height: 32),

            // Today's History
            Text(
              AppStrings.todayHistory,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),

            // Water Logs List
            waterLogsAsync.when(
              data: (logs) {
                if (filter.hasActiveFilters && logs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[600]
                              : Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No water logs found',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            ref.read(waterFilterProvider.notifier).clearFilters();
                          },
                          child: const Text('Clear filters'),
                        ),
                      ],
                    ),
                  );
                }
                return _buildWaterLogsList(logs);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading logs: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle(int totalGlasses) {
    final progress = totalGlasses / _waterGoal;
    final percentage = (progress * 100).toInt();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring (background)
              SizedBox(
                width: 280,
                height: 280,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 20,
                  backgroundColor: isDark 
                      ? Colors.grey[800] 
                      : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
              ),
              // Animated Progress ring
              SizedBox(
                width: 280,
                height: 280,
                child: AnimatedCircularProgressIndicator(
                  value: progress > 1.0 ? 1.0 : progress,
                  strokeWidth: 20,
                  backgroundColor: Colors.transparent,
                  valueColor: progress >= 1.0 ? AppColors.success : AppColors.primary,
                  duration: const Duration(milliseconds: 1500),
                ),
              ),
              // Center content - stacked vertically
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedCounter(
                    value: totalGlasses,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 64,
                          color: progress >= 1.0 ? AppColors.success : AppColors.primary,
                        ),
                    duration: const Duration(milliseconds: 1000),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '/$_waterGoal',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 28,
                          color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: (progress >= 1.0 ? AppColors.success : AppColors.primary)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AnimatedCounter(
                      value: percentage,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: progress >= 1.0 ? AppColors.success : AppColors.primary,
                          ),
                      duration: const Duration(milliseconds: 1000),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAddButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Add:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickAddButton(1),
            _buildQuickAddButton(2),
            _buildQuickAddButton(3),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAddButton(int glasses) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: AppColors.waterGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _addWater(glasses),
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  '$glasses',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaterLogsList(List<WaterLog> logs) {
    if (logs.isEmpty) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.water_drop_outlined,
                size: 64,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No water logged today',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: isDark ? const Color(0xFF1E1E1E) : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.water_drop, color: AppColors.info, size: 20),
            ),
            title: Text('${log.glasses} ${AppStrings.glasses}'),
            subtitle: Text(
              DateHelper.formatTime(
                DateHelper.parseTimeFromDb(log.timestamp),
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
              onPressed: () => _deleteWater(log.id!),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addWater(int glasses) async {
    final today = DateHelper.todayAsString();
    final notifier = ref.read(waterNotifierProvider(today).notifier);
    await notifier.addWater(glasses);

    // Refresh total glasses and filtered water logs if filters are active
    ref.invalidate(todayTotalGlassesProvider);
    ref.invalidate(filteredWaterLogsProvider);

    // Check for achievements
    final achievementService = AchievementService();
    final unlocked = await achievementService.checkAndUnlockAchievements();
    if (unlocked.isNotEmpty && mounted) {
      ref.invalidate(achievementsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Achievement unlocked: ${unlocked.first.title}'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    } else if (mounted) {
      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $glasses ${AppStrings.glasses}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _deleteWater(int id) async {
    final today = DateHelper.todayAsString();
    final notifier = ref.read(waterNotifierProvider(today).notifier);
    await notifier.deleteWater(id);

    // Refresh total glasses and filtered water logs if filters are active
    ref.invalidate(todayTotalGlassesProvider);
    ref.invalidate(filteredWaterLogsProvider);

    // Show snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Water log deleted'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}

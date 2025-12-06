import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_helper.dart';
import '../providers/meal_provider.dart';
import '../../../data/models/meal_log.dart';
import '../../../services/achievement_service.dart';
import '../../insights/providers/achievement_provider.dart';

/// Meal logging screen
class MealLoggingScreen extends ConsumerStatefulWidget {
  const MealLoggingScreen({super.key});

  @override
  ConsumerState<MealLoggingScreen> createState() =>
      _MealLoggingScreenState();
}

class _MealLoggingScreenState extends ConsumerState<MealLoggingScreen> {
  final List<String> _mealTypes = [
    AppStrings.breakfast,
    AppStrings.lunch,
    AppStrings.dinner,
    AppStrings.snack,
  ];

  final Map<String, IconData> _mealIcons = {
    AppStrings.breakfast: Icons.breakfast_dining,
    AppStrings.lunch: Icons.lunch_dining,
    AppStrings.dinner: Icons.dinner_dining,
    AppStrings.snack: Icons.fastfood,
  };

  final Map<String, Color> _mealColors = {
    AppStrings.breakfast: Colors.orange,
    AppStrings.lunch: Colors.blue,
    AppStrings.dinner: Colors.purple,
    AppStrings.snack: Colors.green,
  };

  @override
  Widget build(BuildContext context) {
    final today = DateHelper.todayAsString();
    final mealLogsAsync = ref.watch(mealNotifierProvider(today));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Logging'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Log Buttons
            Text(
              'Quick Log Meal:',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            _buildMealTypeButtons(),
            const SizedBox(height: 32),

            // Today's Meals
            Text(
              "Today's Meals",
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),

            // Meal Logs List
            mealLogsAsync.when(
              data: (logs) => _buildMealLogsList(logs),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading meals: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeButtons() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: _mealTypes.length,
      itemBuilder: (context, index) {
        final mealType = _mealTypes[index];
        return _buildMealTypeButton(mealType);
      },
    );
  }

  Widget _buildMealTypeButton(String mealType) {
    return ElevatedButton.icon(
      onPressed: () => _logMeal(mealType),
      style: ElevatedButton.styleFrom(
        backgroundColor: _mealColors[mealType]?.withOpacity(0.1),
        foregroundColor: _mealColors[mealType],
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: Icon(_mealIcons[mealType]),
      label: Text(mealType),
    );
  }

  Widget _buildMealLogsList(List<MealLog> logs) {
    if (logs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.restaurant_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No meals logged today',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
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
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _mealColors[log.mealType]?.withOpacity(0.2),
              child: Icon(
                _mealIcons[log.mealType],
                color: _mealColors[log.mealType],
              ),
            ),
            title: Text(
              log.mealType,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateHelper.formatTime(
                    DateHelper.parseTimeFromDb(log.time),
                  ),
                ),
                if (log.notes != null && log.notes!.isNotEmpty)
                  Text(
                    log.notes!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteMeal(log.id!),
            ),
          ),
        );
      },
    );
  }

  Future<void> _logMeal(String mealType) async {
    final now = DateTime.now();
    final today = DateHelper.todayAsString();
    final notifier = ref.read(mealNotifierProvider(today).notifier);

    // Show dialog for optional notes
    final notes = await showDialog<String>(
      context: context,
      builder: (context) => _buildMealNotesDialog(mealType),
    );

    await notifier.addMeal(
      mealType: mealType,
      dateTime: now,
      notes: notes,
    );

    // Check for achievements after logging
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
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$mealType logged successfully'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Widget _buildMealNotesDialog(String mealType) {
    final notesController = TextEditingController();
    return AlertDialog(
      title: Text('Log $mealType'),
      content: TextField(
        controller: notesController,
        decoration: const InputDecoration(
          labelText: 'Notes (optional)',
          hintText: 'What did you eat?',
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, notesController.text),
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }

  Future<void> _deleteMeal(int id) async {
    final today = DateHelper.todayAsString();
    final notifier = ref.read(mealNotifierProvider(today).notifier);
    await notifier.deleteMeal(id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal deleted'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}

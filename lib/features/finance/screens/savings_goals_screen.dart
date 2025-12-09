import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/widgets/animated_progress_indicator.dart';
import '../providers/savings_provider.dart';
import '../../../data/models/savings_goal.dart';
import 'add_savings_goal_screen.dart';

/// Savings goals screen
class SavingsGoalsScreen extends ConsumerWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                PageTransitions.slideUpRoute(
                  const AddSavingsGoalScreen(),
                ),
              );
              ref.invalidate(savingsNotifierProvider);
            },
          ),
        ],
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.savings_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No savings goals',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create a savings goal',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                if (goal.targetDate != null)
                                  Text(
                                    'Target: ${DateHelper.formatDate(DateHelper.parseDateFromDb(goal.targetDate!))}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          if (goal.isGoalCompleted)
                            Chip(
                              label: const Text('Completed'),
                              backgroundColor: AppColors.success.withOpacity(0.2),
                              labelStyle: const TextStyle(color: AppColors.success),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress Bar
                      AnimatedProgressIndicator(
                        value: goal.progress > 1.0 ? 1.0 : goal.progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: goal.isGoalCompleted
                              ? AppColors.success
                              : AppColors.primary,
                        duration: const Duration(milliseconds: 1000),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Saved',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'RM${goal.currentAmount.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${(goal.progress * 100).toStringAsFixed(0)}%',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: goal.isGoalCompleted
                                          ? AppColors.success
                                          : AppColors.primary,
                                    ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Target',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'RM${goal.targetAmount.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (!goal.isGoalCompleted) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showAddAmountDialog(context, ref, goal),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Amount'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () => _showGoalMenu(context, ref, goal),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading goals: $error'),
        ),
      ),
    );
  }

  void _showAddAmountDialog(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
  ) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add to ${goal.name}'),
        content: TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount (USD)',
            prefixText: 'RM',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                final notifier = ref.read(savingsNotifierProvider.notifier);
                await notifier.addToGoal(goal.id!, amount);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added RM${amount.toStringAsFixed(2)}')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showGoalMenu(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!goal.isGoalCompleted)
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Mark as Completed'),
                onTap: () async {
                  Navigator.pop(context);
                  final notifier = ref.read(savingsNotifierProvider.notifier);
                  await notifier.completeGoal(goal.id!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Goal marked as completed')),
                    );
                  }
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Goal'),
                    content: Text('Are you sure you want to delete ${goal.name}?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(AppStrings.cancel),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: const Text(AppStrings.delete),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  final notifier = ref.read(savingsNotifierProvider.notifier);
                  await notifier.deleteGoal(goal.id!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Goal deleted')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

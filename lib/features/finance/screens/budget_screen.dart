import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/page_transitions.dart';
import '../providers/budget_provider.dart';
import '../../../data/models/budget_category.dart';
import 'add_budget_category_screen.dart';

/// Budget management screen
class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetProgressAsync = ref.watch(budgetProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.budgetManager),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                PageTransitions.slideUpRoute(
                  const AddBudgetCategoryScreen(),
                ),
              );
              ref.invalidate(budgetProgressProvider);
              ref.invalidate(budgetNotifierProvider);
            },
          ),
        ],
      ),
      body: budgetProgressAsync.when(
        data: (categoriesWithProgress) {
          if (categoriesWithProgress.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No budget categories',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a budget category',
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
            itemCount: categoriesWithProgress.length,
            itemBuilder: (context, index) {
              final entry = categoriesWithProgress.entries.elementAt(index);
              final category = entry.key;
              final progress = entry.value;
              final spending = progress['spending']!;
              final progressValue = progress['progress']!;
              final remaining = progress['remaining']!;

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
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                child: Icon(
                                  Icons.category,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                category.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () => _showCategoryMenu(
                              context,
                              ref,
                              category,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress Bar
                      LinearProgressIndicator(
                        value: progressValue > 1.0 ? 1.0 : progressValue,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressValue >= 1.0
                              ? AppColors.error
                              : progressValue >= 0.8
                                  ? AppColors.warning
                                  : AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Spent',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'RM${spending.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${(progressValue * 100).toStringAsFixed(0)}%',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: progressValue >= 1.0
                                          ? AppColors.error
                                          : progressValue >= 0.8
                                              ? AppColors.warning
                                              : AppColors.success,
                                    ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                remaining >= 0 ? 'Remaining' : 'Over budget',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'RM${remaining.abs().toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: remaining >= 0
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Limit: RM${category.monthlyLimit.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading budgets: $error'),
        ),
      ),
    );
  }

  void _showCategoryMenu(
    BuildContext context,
    WidgetRef ref,
    BudgetCategory category,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit screen
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
                    title: const Text('Delete Category'),
                    content: Text('Are you sure you want to delete ${category.name}?'),
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
                  final notifier = ref.read(budgetNotifierProvider.notifier);
                  await notifier.deleteCategory(category.id!);
                  ref.invalidate(budgetProgressProvider);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Category deleted')),
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

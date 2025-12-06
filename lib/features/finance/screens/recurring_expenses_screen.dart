import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/page_transitions.dart';
import '../providers/recurring_expense_provider.dart';
import '../../../data/models/recurring_expense.dart';
import 'add_recurring_expense_screen.dart';
import '../providers/expense_provider.dart';
import '../../../data/models/expense.dart';
import '../../../core/utils/date_helper.dart';

/// Recurring expenses screen
class RecurringExpensesScreen extends ConsumerWidget {
  const RecurringExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringExpensesAsync = ref.watch(recurringExpenseNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                PageTransitions.slideUpRoute(
                  const AddRecurringExpenseScreen(),
                ),
              );
              ref.invalidate(recurringExpenseNotifierProvider);
            },
          ),
        ],
      ),
      body: recurringExpensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.repeat,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recurring expenses',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a recurring expense',
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
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: expense.isActive == 1
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    child: Icon(
                      _getCategoryIcon(expense.category),
                      color: expense.isActive == 1
                          ? AppColors.primary
                          : Colors.grey,
                    ),
                  ),
                  title: Text(
                    expense.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: expense.isActive == 0
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(expense.category),
                      Text(
                        _getFrequencyText(expense),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'RM${expense.amount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                      Switch(
                        value: expense.isActive == 1,
                        onChanged: (value) {
                          final notifier =
                              ref.read(recurringExpenseNotifierProvider.notifier);
                          notifier.toggleActive(expense.id!, value);
                        },
                      ),
                    ],
                  ),
                  onTap: () => _showExpenseMenu(context, ref, expense),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading recurring expenses: $error'),
        ),
      ),
    );
  }

  String _getFrequencyText(RecurringExpense expense) {
    if (expense.frequency == 'monthly' && expense.dayOfMonth != null) {
      return 'Monthly on day ${expense.dayOfMonth}';
    } else if (expense.frequency == 'weekly') {
      return 'Weekly';
    }
    return 'Recurring';
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

  void _showExpenseMenu(
    BuildContext context,
    WidgetRef ref,
    RecurringExpense expense,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_shopping_cart),
              title: const Text('Log Expense Now'),
              onTap: () async {
                Navigator.pop(context);
                await _logExpenseNow(context, ref, expense);
              },
            ),
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
                    title: const Text('Delete Recurring Expense'),
                    content: Text('Are you sure you want to delete ${expense.name}?'),
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
                  final notifier =
                      ref.read(recurringExpenseNotifierProvider.notifier);
                  await notifier.deleteRecurringExpense(expense.id!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Recurring expense deleted')),
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

  Future<void> _logExpenseNow(
    BuildContext context,
    WidgetRef ref,
    RecurringExpense recurringExpense,
  ) async {
    final now = DateTime.now();
    final expense = Expense(
      amount: recurringExpense.amount,
      category: recurringExpense.category,
      description: recurringExpense.name,
      date: DateHelper.formatDateForDb(now),
      time: DateHelper.formatTimeForDb(now),
    );

    final today = DateHelper.todayAsString();
    final notifier = ref.read(expenseNotifierProvider(today).notifier);
    await notifier.addExpense(expense);

    // Refresh totals and expense list
    ref.invalidate(todayTotalExpensesProvider);
    ref.invalidate(currentMonthTotalProvider);
    ref.invalidate(expenseNotifierProvider(today));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${recurringExpense.name} logged as expense'),
        ),
      );
    }
  }
}

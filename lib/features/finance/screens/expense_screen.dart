import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/widgets/gradient_card.dart';
import '../providers/expense_provider.dart';
import '../providers/expense_category_provider.dart';
import '../widgets/expense_filter_widget.dart';
import '../../settings/providers/currency_provider.dart';
import '../../../data/models/expense.dart';
import '../../../data/models/expense_category.dart';
import 'add_expense_screen.dart';

/// Expense tracking screen
class ExpenseScreen extends ConsumerWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateHelper.todayAsString();
    final filter = ref.watch(expenseFilterProvider);
    final expensesAsync = filter.hasActiveFilters
        ? ref.watch(filteredExpensesProvider)
        : ref.watch(expenseNotifierProvider(today));
    final totalAsync = ref.watch(todayTotalExpensesProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
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
                builder: (context) => const ExpenseFilterWidget(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddExpenseScreen(),
                ),
              );
              // Refresh expenses after adding
              ref.invalidate(expenseNotifierProvider(today));
              ref.invalidate(filteredExpensesProvider);
              ref.invalidate(todayTotalExpensesProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Today's Total Card
          GradientCard(
            gradient: AppColors.financeGradient,
            margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
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
                  ],
                ),
                const SizedBox(height: 12),
                  Text(
                    "Today's Spending",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                  ),
                  const SizedBox(height: 8),
                  totalAsync.when(
                    data: (total) => Text(
                    CurrencyHelper.formatAmount(total, currency),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 36,
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
                ],
            ),
          ),

          // Expenses List
          Expanded(
            child: expensesAsync.when(
              data: (expenses) {
                if (filter.hasActiveFilters && expenses.isEmpty) {
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
                          'No expenses found',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            ref.read(expenseFilterProvider.notifier).clearFilters();
                          },
                          child: const Text('Clear filters'),
                        ),
                      ],
                    ),
                  );
                }
                return _buildExpensesList(context, ref, expenses, currency);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading expenses: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList(
    BuildContext context,
    WidgetRef ref,
    List<Expense> expenses,
    String currency,
  ) {
    if (expenses.isEmpty) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses today',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add an expense',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          color: isDark ? const Color(0xFF1E1E1E) : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: expense.receiptPhotoPath != null && expense.receiptPhotoPath!.isNotEmpty
                ? () => _showReceiptPhoto(context, expense.receiptPhotoPath!)
                : null,
            onLongPress: () => _showDeleteDialog(context, ref, expense),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildCategoryAvatar(context, ref, expense.category),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.category,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        if (expense.description != null && expense.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              expense.description!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        Row(
                          children: [
                            Text(
                              DateHelper.formatTime(
                                DateHelper.parseTimeFromDb(expense.time),
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (expense.receiptPhotoPath != null && expense.receiptPhotoPath!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.receipt,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyHelper.formatAmount(expense.amount, currency),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryAvatar(BuildContext context, WidgetRef ref, String categoryName) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    
    return categoriesAsync.when(
      data: (categories) {
        final category = categories.firstWhere(
          (c) => c.name == categoryName,
          orElse: () => ExpenseCategory(
            name: categoryName,
            iconName: Icons.category.codePoint.toString(),
            colorHex: '#6366F1',
          ),
        );
        return CircleAvatar(
          backgroundColor: category.color.withOpacity(0.1),
          child: Icon(
            category.iconData,
            color: category.color,
          ),
        );
      },
      loading: () => const CircleAvatar(
        backgroundColor: AppColors.primary,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: const Icon(Icons.category, color: AppColors.primary),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final today = DateHelper.todayAsString();
              final notifier = ref.read(expenseNotifierProvider(today).notifier);
              await notifier.deleteExpense(expense.id!);
              
              // Refresh totals
              ref.invalidate(todayTotalExpensesProvider);
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Expense deleted')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _showReceiptPhoto(BuildContext context, String photoPath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(photoPath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

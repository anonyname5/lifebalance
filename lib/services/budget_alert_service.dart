import '../data/repositories/budget_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../services/notification_service.dart';
import '../core/utils/date_helper.dart';

/// Service for monitoring budget progress and sending alerts
class BudgetAlertService {
  final BudgetRepository _budgetRepository = BudgetRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();

  /// Check all budget categories and send alerts if needed
  Future<void> checkAndSendBudgetAlerts() async {
    try {
      final categories = await _budgetRepository.getAllBudgetCategories();
      final activeCategories = categories.where((c) => c.isActive == 1).toList();

      for (var category in activeCategories) {
        final spending = await _budgetRepository.getCategorySpendingThisMonth(
          category.name,
        );
        final limit = category.monthlyLimit;
        final percentage = (spending / limit) * 100;

        // Send alert if over 80% or exceeded
        if (percentage >= 80) {
          await NotificationService.instance.scheduleBudgetAlert(
            categoryName: category.name,
            spent: spending,
            limit: limit,
            percentage: percentage,
          );
        }
      }
    } catch (e) {
      // Silently fail - don't interrupt app
      print('Error checking budget alerts: $e');
    }
  }

  /// Check budget for a specific category
  Future<void> checkCategoryBudget(String categoryName) async {
    try {
      final category = await _budgetRepository.getBudgetCategoryByName(categoryName);
      if (category == null || category.isActive != 1) return;

      final spending = await _budgetRepository.getCategorySpendingThisMonth(categoryName);
      final limit = category.monthlyLimit;
      final percentage = (spending / limit) * 100;

      if (percentage >= 80) {
        await NotificationService.instance.scheduleBudgetAlert(
          categoryName: categoryName,
          spent: spending,
          limit: limit,
          percentage: percentage,
        );
      }
    } catch (e) {
      print('Error checking category budget: $e');
    }
  }
}

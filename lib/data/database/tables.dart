/// Database table names and column definitions
class Tables {
  static const String userProfile = 'user_profile';
  static const String waterLogs = 'water_logs';
  static const String mealLogs = 'meal_logs';
  static const String expenses = 'expenses';
  static const String budgetCategories = 'budget_categories';
  static const String savingsGoals = 'savings_goals';
  static const String recurringExpenses = 'recurring_expenses';
  static const String expenseCategories = 'expense_categories';

  // User Profile columns
  static const String userId = 'id';
  static const String userName = 'name';
  static const String monthlyIncome = 'monthly_income';
  static const String waterGoal = 'water_goal';
  static const String profilePicturePath = 'profile_picture_path';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';

  // Water Logs columns
  static const String waterLogId = 'id';
  static const String date = 'date';
  static const String glasses = 'glasses';
  static const String timestamp = 'timestamp';

  // Meal Logs columns
  static const String mealLogId = 'id';
  static const String mealType = 'meal_type';
  static const String time = 'time';
  static const String notes = 'notes';

  // Expenses columns
  static const String expenseId = 'id';
  static const String amount = 'amount';
  static const String category = 'category';
  static const String description = 'description';
  static const String receiptPhotoPath = 'receipt_photo_path';

  // Budget Categories columns
  static const String budgetCategoryId = 'id';
  static const String categoryName = 'name';
  static const String monthlyLimit = 'monthly_limit';
  static const String color = 'color';
  static const String icon = 'icon';
  static const String isActive = 'is_active';

  // Savings Goals columns
  static const String savingsGoalId = 'id';
  static const String goalName = 'name';
  static const String targetAmount = 'target_amount';
  static const String currentAmount = 'current_amount';
  static const String targetDate = 'target_date';
  static const String isCompleted = 'is_completed';

  // Recurring Expenses columns
  static const String recurringExpenseId = 'id';
  static const String recurringName = 'name';
  static const String recurringAmount = 'amount';
  static const String recurringCategory = 'category';
  static const String frequency = 'frequency';
  static const String dayOfMonth = 'day_of_month';

  // Expense Categories columns
  static const String expenseCategoryId = 'id';
  static const String expenseCategoryName = 'name';
  static const String iconName = 'icon_name';
  static const String colorHex = 'color_hex';
  static const String expenseCategoryIsDefault = 'is_default';
  static const String expenseCategoryIsActive = 'is_active';
}

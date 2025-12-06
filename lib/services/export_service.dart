import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../data/repositories/water_repository.dart';
import '../data/repositories/meal_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/savings_repository.dart';
import '../data/repositories/recurring_expense_repository.dart';
import '../core/utils/date_helper.dart';

/// Service for exporting data to CSV and PDF
class ExportService {
  final WaterRepository _waterRepository = WaterRepository();
  final MealRepository _mealRepository = MealRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final BudgetRepository _budgetRepository = BudgetRepository();
  final SavingsRepository _savingsRepository = SavingsRepository();
  final RecurringExpenseRepository _recurringRepository =
      RecurringExpenseRepository();

  /// Export all data to CSV
  Future<File> exportToCSV() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${directory.path}/lifebalance_export_$timestamp.csv');

    final csvData = <List<dynamic>>[];

    // Header
    csvData.add([
      'Data Type',
      'Date',
      'Time',
      'Amount/Value',
      'Category/Type',
      'Description/Notes',
      'Additional Info',
    ]);

    // Water Logs
    final waterLogs = await _waterRepository.getWaterLogsByDateRange(
      DateHelper.formatDateForDb(DateTime.now().subtract(const Duration(days: 365))),
      DateHelper.formatDateForDb(DateTime.now()),
    );
    for (var log in waterLogs) {
      csvData.add([
        'Water Intake',
        log.date,
        log.timestamp,
        '${log.glasses} glasses',
        '',
        '',
        '',
      ]);
    }

    // Meal Logs
    final mealLogs = await _mealRepository.getMealLogsByDateRange(
      DateHelper.formatDateForDb(DateTime.now().subtract(const Duration(days: 365))),
      DateHelper.formatDateForDb(DateTime.now()),
    );
    for (var log in mealLogs) {
      csvData.add([
        'Meal',
        log.date,
        log.time,
        '',
        log.mealType,
        log.notes ?? '',
        '',
      ]);
    }

    // Expenses
    final expenses = await _expenseRepository.getExpensesByDateRange(
      DateHelper.formatDateForDb(DateTime.now().subtract(const Duration(days: 365))),
      DateHelper.formatDateForDb(DateTime.now()),
    );
    for (var expense in expenses) {
      csvData.add([
        'Expense',
        expense.date,
        expense.time,
        expense.amount.toStringAsFixed(2),
        expense.category,
        expense.description ?? '',
        '',
      ]);
    }

    // Budget Categories
    final budgets = await _budgetRepository.getAllBudgetCategories();
    for (var budget in budgets) {
      csvData.add([
        'Budget Category',
        '',
        '',
        budget.monthlyLimit.toStringAsFixed(2),
        budget.name,
        '',
        'Active: ${budget.isActive == 1}',
      ]);
    }

    // Savings Goals
    final savings = await _savingsRepository.getAllSavingsGoals();
    for (var goal in savings) {
      csvData.add([
        'Savings Goal',
        goal.targetDate ?? '',
        '',
        '${goal.currentAmount.toStringAsFixed(2)} / ${goal.targetAmount.toStringAsFixed(2)}',
        goal.name,
        '',
        'Completed: ${goal.isCompleted == 1}',
      ]);
    }

    // Recurring Expenses
    final recurring = await _recurringRepository.getAllRecurringExpenses();
    for (var expense in recurring) {
      csvData.add([
        'Recurring Expense',
        '',
        '',
        expense.amount.toStringAsFixed(2),
        expense.category,
        expense.name,
        '${expense.frequency} - Day ${expense.dayOfMonth ?? "N/A"}',
      ]);
    }

    final csvString = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvString);

    return file;
  }

  /// Export all data to PDF
  Future<File> exportToPDF() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${directory.path}/lifebalance_export_$timestamp.pdf');

    final pdf = pw.Document();

    // Get all data
    final waterLogs = await _waterRepository.getWaterLogsByDateRange(
      DateHelper.formatDateForDb(DateTime.now().subtract(const Duration(days: 365))),
      DateHelper.formatDateForDb(DateTime.now()),
    );
    final mealLogs = await _mealRepository.getMealLogsByDateRange(
      DateHelper.formatDateForDb(DateTime.now().subtract(const Duration(days: 365))),
      DateHelper.formatDateForDb(DateTime.now()),
    );
    final expenses = await _expenseRepository.getExpensesByDateRange(
      DateHelper.formatDateForDb(DateTime.now().subtract(const Duration(days: 365))),
      DateHelper.formatDateForDb(DateTime.now()),
    );
    final budgets = await _budgetRepository.getAllBudgetCategories();
    final savings = await _savingsRepository.getAllSavingsGoals();
    final recurring = await _recurringRepository.getAllRecurringExpenses();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Title
            pw.Header(
              level: 0,
              child: pw.Text(
                'LifeBalance Data Export',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Generated: ${DateHelper.formatFullDate(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 30),

            // Water Logs
            pw.Header(level: 1, child: pw.Text('Water Intake Logs')),
            pw.Table(
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Glasses', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                ...waterLogs.take(50).map((log) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(log.date),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('${log.glasses}'),
                        ),
                      ],
                    )),
              ],
            ),
            pw.SizedBox(height: 20),

            // Expenses
            pw.Header(level: 1, child: pw.Text('Expenses')),
            pw.Table(
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                ...expenses.take(50).map((expense) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(expense.date),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('RM${expense.amount.toStringAsFixed(2)}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(expense.category),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(expense.description ?? ''),
                        ),
                      ],
                    )),
              ],
            ),
            pw.SizedBox(height: 20),

            // Summary
            pw.Header(level: 1, child: pw.Text('Summary')),
            pw.Text('Total Water Logs: ${waterLogs.length}'),
            pw.Text('Total Meal Logs: ${mealLogs.length}'),
            pw.Text('Total Expenses: ${expenses.length}'),
            pw.Text('Budget Categories: ${budgets.length}'),
            pw.Text('Savings Goals: ${savings.length}'),
            pw.Text('Recurring Expenses: ${recurring.length}'),
          ];
        },
      ),
    );

    await file.writeAsBytes(await pdf.save());
    return file;
  }
}

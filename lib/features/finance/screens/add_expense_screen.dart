import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/utils/currency_helper.dart';
import '../providers/expense_provider.dart';
import '../providers/expense_category_provider.dart';
import '../../settings/providers/currency_provider.dart';
import '../../../data/models/expense.dart';
import '../../../data/models/expense_category.dart';
import '../../../services/budget_alert_service.dart';
import '../../../services/receipt_photo_service.dart';

/// Add expense screen
class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  ExpenseCategory? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _receiptPhotoPath;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final categoriesAsync = ref.watch(expenseCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addExpense),
        actions: [
          TextButton(
            onPressed: _saveExpense,
            child: const Text(
              AppStrings.save,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: CurrencyHelper.getLabelText(AppStrings.amount, currency),
                  prefixText: CurrencyHelper.getPrefixText(currency),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category Selection
              Text(
                AppStrings.category,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return const Text('No categories available. Please add categories in settings.');
                  }

                  // Set default selected category if not set
                  if (_selectedCategory == null && categories.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _selectedCategory = categories.first;
                      });
                    });
                  }

                  return Wrap(
                spacing: 8,
                runSpacing: 8,
                    children: categories.map((category) {
                      final isSelected = _selectedCategory?.id == category.id;
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                              category.iconData,
                          size: 18,
                              color: category.color,
                        ),
                        const SizedBox(width: 4),
                            Text(category.name),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                        selectedColor: category.color.withOpacity(0.2),
                        checkmarkColor: category.color,
                  );
                }).toList(),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error loading categories: $error'),
              ),
              const SizedBox(height: 24),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '${AppStrings.description} (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Receipt Photo
              Text(
                'Receipt Photo (optional)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_receiptPhotoPath != null) ...[
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_receiptPhotoPath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () {
                        setState(() {
                          _receiptPhotoPath = null;
                        });
                      },
                    ),
                  ] else ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showReceiptPhotoPicker(context),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Add Receipt Photo'),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Date & Time Selection
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Date'),
                      subtitle: Text(DateHelper.formatDate(_selectedDate)),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('Time'),
                      subtitle: Text(_selectedTime.format(context)),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (time != null) {
                          setState(() {
                            _selectedTime = time;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showReceiptPhotoPicker(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final photoPath = await ReceiptPhotoService.instance.pickReceiptFromGallery();
                if (photoPath != null && mounted) {
                  setState(() {
                    _receiptPhotoPath = photoPath;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final photoPath = await ReceiptPhotoService.instance.pickReceiptFromCamera();
                if (photoPath != null && mounted) {
                  setState(() {
                    _receiptPhotoPath = photoPath;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final amount = double.parse(_amountController.text);
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final expense = Expense(
      amount: amount,
      category: _selectedCategory!.name,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      date: DateHelper.formatDateForDb(dateTime),
      time: DateHelper.formatTimeForDb(dateTime),
      receiptPhotoPath: _receiptPhotoPath,
    );

    final today = DateHelper.todayAsString();
    final notifier = ref.read(expenseNotifierProvider(today).notifier);
    await notifier.addExpense(expense);

    // Refresh totals
    ref.invalidate(todayTotalExpensesProvider);
    ref.invalidate(currentMonthTotalProvider);

    // Check budget alerts for this category
    final budgetAlertService = BudgetAlertService();
    await budgetAlertService.checkCategoryBudget(_selectedCategory!.name);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully')),
      );
    }
  }
}

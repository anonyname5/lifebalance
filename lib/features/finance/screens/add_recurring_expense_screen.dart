import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/currency_helper.dart';
import '../../settings/providers/currency_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../providers/recurring_expense_provider.dart';
import '../../../data/models/recurring_expense.dart';

/// Add recurring expense screen
class AddRecurringExpenseScreen extends ConsumerStatefulWidget {
  const AddRecurringExpenseScreen({super.key});

  @override
  ConsumerState<AddRecurringExpenseScreen> createState() =>
      _AddRecurringExpenseScreenState();
}

class _AddRecurringExpenseScreenState
    extends ConsumerState<AddRecurringExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Bills';
  String _selectedFrequency = 'monthly';
  int? _selectedDayOfMonth;

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Health',
    'Education',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDayOfMonth = DateTime.now().day;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recurring Expense'),
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
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Expense Name',
                  hintText: 'e.g., Rent, Netflix Subscription',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an expense name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Amount Field
              Consumer(
                builder: (context, ref, child) {
                  final currency = ref.watch(currencyProvider);
                  return TextFormField(
                controller: _amountController,
                    decoration: InputDecoration(
                      labelText: CurrencyHelper.getLabelText('Amount', currency),
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
                  );
                },
              ),
              const SizedBox(height: 24),

              // Category Selection
              Text(
                AppStrings.category,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Frequency Selection
              Text(
                'Frequency',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'monthly',
                    label: Text('Monthly'),
                    icon: Icon(Icons.calendar_month),
                  ),
                  ButtonSegment(
                    value: 'weekly',
                    label: Text('Weekly'),
                    icon: Icon(Icons.event_repeat),
                  ),
                ],
                selected: {_selectedFrequency},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedFrequency = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Day of Month (for monthly)
              if (_selectedFrequency == 'monthly') ...[
                Text(
                  'Day of Month',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _selectedDayOfMonth,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select day',
                  ),
                  items: List.generate(31, (index) {
                    final day = index + 1;
                    return DropdownMenuItem(
                      value: day,
                      child: Text('Day $day'),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _selectedDayOfMonth = value;
                    });
                  },
                  validator: (value) {
                    if (_selectedFrequency == 'monthly' && value == null) {
                      return 'Please select a day';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final expense = RecurringExpense(
      name: _nameController.text,
      amount: double.parse(_amountController.text),
      category: _selectedCategory,
      frequency: _selectedFrequency,
      dayOfMonth: _selectedFrequency == 'monthly' ? _selectedDayOfMonth : null,
    );

    final notifier = ref.read(recurringExpenseNotifierProvider.notifier);
    await notifier.addRecurringExpense(expense);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recurring expense added successfully')),
      );
    }
  }
}

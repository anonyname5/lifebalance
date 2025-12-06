import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_helper.dart';
import '../../settings/providers/currency_provider.dart';
import '../providers/budget_provider.dart';
import '../../../data/models/budget_category.dart';

/// Add budget category screen
class AddBudgetCategoryScreen extends ConsumerStatefulWidget {
  const AddBudgetCategoryScreen({super.key});

  @override
  ConsumerState<AddBudgetCategoryScreen> createState() =>
      _AddBudgetCategoryScreenState();
}

class _AddBudgetCategoryScreenState
    extends ConsumerState<AddBudgetCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _limitController = TextEditingController();
  String _selectedCategory = 'Food';

  final List<String> _predefinedCategories = [
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
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Budget Category'),
        actions: [
          TextButton(
            onPressed: _saveCategory,
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
              // Category Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g., Food, Transport',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Quick Select
              Text(
                'Or select from common categories:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _predefinedCategories.map((category) {
                  return FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _nameController.text = category;
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Monthly Limit
              Consumer(
                builder: (context, ref, child) {
                  final currency = ref.watch(currencyProvider);
                  return TextFormField(
                controller: _limitController,
                    decoration: InputDecoration(
                      labelText: CurrencyHelper.getLabelText('Monthly Limit', currency),
                      prefixText: CurrencyHelper.getPrefixText(currency),
                      border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a monthly limit';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final category = BudgetCategory(
      name: _nameController.text,
      monthlyLimit: double.parse(_limitController.text),
    );

    final notifier = ref.read(budgetNotifierProvider.notifier);
    await notifier.addCategory(category);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget category added successfully')),
      );
    }
  }
}

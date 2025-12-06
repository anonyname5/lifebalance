import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/currency_helper.dart';
import '../../settings/providers/currency_provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_helper.dart';
import '../providers/savings_provider.dart';
import '../../../data/models/savings_goal.dart';

/// Add savings goal screen
class AddSavingsGoalScreen extends ConsumerStatefulWidget {
  const AddSavingsGoalScreen({super.key});

  @override
  ConsumerState<AddSavingsGoalScreen> createState() =>
      _AddSavingsGoalScreenState();
}

class _AddSavingsGoalScreenState
    extends ConsumerState<AddSavingsGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  DateTime? _targetDate;

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Savings Goal'),
        actions: [
          TextButton(
            onPressed: _saveGoal,
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
              // Goal Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Goal Name',
                  hintText: 'e.g., Vacation, Emergency Fund',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a goal name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Target Amount
              Consumer(
                builder: (context, ref, child) {
                  final currency = ref.watch(currencyProvider);
                  return TextFormField(
                controller: _targetAmountController,
                    decoration: InputDecoration(
                      labelText: CurrencyHelper.getLabelText('Target Amount', currency),
                      prefixText: CurrencyHelper.getPrefixText(currency),
                      border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a target amount';
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

              // Target Date (Optional)
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Target Date (Optional)'),
                subtitle: Text(
                  _targetDate != null
                      ? DateHelper.formatDate(_targetDate!)
                      : 'No date set',
                ),
                trailing: _targetDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _targetDate = null;
                          });
                        },
                      )
                    : null,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (date != null) {
                    setState(() {
                      _targetDate = date;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final goal = SavingsGoal(
      name: _nameController.text,
      targetAmount: double.parse(_targetAmountController.text),
      targetDate: _targetDate != null
          ? DateHelper.formatDateForDb(_targetDate!)
          : null,
    );

    final notifier = ref.read(savingsNotifierProvider.notifier);
    await notifier.addGoal(goal);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Savings goal created successfully')),
      );
    }
  }
}

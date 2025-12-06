import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/utils/currency_helper.dart';
import '../providers/expense_category_provider.dart';
import '../../settings/providers/currency_provider.dart';

/// Filter state for expenses
class ExpenseFilter {
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final String? searchQuery;

  ExpenseFilter({
    this.category,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.searchQuery,
  });

  ExpenseFilter copyWith({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
  }) {
    return ExpenseFilter(
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasActiveFilters {
    return category != null ||
        startDate != null ||
        endDate != null ||
        minAmount != null ||
        maxAmount != null ||
        (searchQuery != null && searchQuery!.isNotEmpty);
  }
}

/// Provider for expense filter
final expenseFilterProvider = StateNotifierProvider<ExpenseFilterNotifier, ExpenseFilter>((ref) {
  return ExpenseFilterNotifier();
});

class ExpenseFilterNotifier extends StateNotifier<ExpenseFilter> {
  ExpenseFilterNotifier() : super(ExpenseFilter());

  void setCategory(String? category) {
    state = state.copyWith(category: category);
  }

  void setStartDate(DateTime? date) {
    state = state.copyWith(startDate: date);
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: date);
  }

  void setMinAmount(double? amount) {
    state = state.copyWith(minAmount: amount);
  }

  void setMaxAmount(double? amount) {
    state = state.copyWith(maxAmount: amount);
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearFilters() {
    state = ExpenseFilter();
  }
}

/// Filter bottom sheet widget
class ExpenseFilterWidget extends ConsumerStatefulWidget {
  const ExpenseFilterWidget({super.key});

  @override
  ConsumerState<ExpenseFilterWidget> createState() => _ExpenseFilterWidgetState();
}

class _ExpenseFilterWidgetState extends ConsumerState<ExpenseFilterWidget> {
  final _searchController = TextEditingController();
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();
  bool _controllersInitialized = false;

  void _syncControllersWithFilter(ExpenseFilter filter) {
    if (!_controllersInitialized) {
      _searchController.text = filter.searchQuery ?? '';
      _minAmountController.text = filter.minAmount != null ? filter.minAmount!.toStringAsFixed(2) : '';
      _maxAmountController.text = filter.maxAmount != null ? filter.maxAmount!.toStringAsFixed(2) : '';
      _controllersInitialized = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(expenseFilterProvider);
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final currency = ref.watch(currencyProvider);
    
    // Sync controllers with filter state
    _syncControllersWithFilter(filter);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Search',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (filter.hasActiveFilters)
                TextButton(
                  onPressed: () {
                    ref.read(expenseFilterProvider.notifier).clearFilters();
                    _searchController.clear();
                    _minAmountController.clear();
                    _maxAmountController.clear();
                  },
                  child: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search by description',
              hintText: 'Enter keywords...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(expenseFilterProvider.notifier).setSearchQuery(null);
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              ref.read(expenseFilterProvider.notifier).setSearchQuery(
                    value.isEmpty ? null : value,
                  );
            },
          ),
          const SizedBox(height: 16),

          // Category filter
          Text(
            'Category',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          categoriesAsync.when(
            data: (categories) => SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: filter.category == null,
                        onSelected: (selected) {
                          ref.read(expenseFilterProvider.notifier).setCategory(null);
                        },
                      ),
                    );
                  }
                  final category = categories[index - 1];
                  final isSelected = filter.category == category.name;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(
                        category.iconData,
                        size: 18,
                        color: isSelected ? Colors.white : category.color,
                      ),
                      label: Text(category.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        ref.read(expenseFilterProvider.notifier).setCategory(
                              selected ? category.name : null,
                            );
                      },
                    ),
                  );
                },
              ),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Error loading categories'),
          ),
          const SizedBox(height: 16),

          // Date range
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: filter.startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      ref.read(expenseFilterProvider.notifier).setStartDate(date);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                    ),
                    child: Text(
                      filter.startDate != null
                          ? DateHelper.formatDate(filter.startDate!)
                          : 'Select date',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: filter.endDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      ref.read(expenseFilterProvider.notifier).setEndDate(date);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                    ),
                    child: Text(
                      filter.endDate != null
                          ? DateHelper.formatDate(filter.endDate!)
                          : 'Select date',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Amount range
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minAmountController,
                  decoration: InputDecoration(
                    labelText: 'Min Amount',
                    prefixText: CurrencyHelper.getPrefixText(currency),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  onChanged: (value) {
                    ref.read(expenseFilterProvider.notifier).setMinAmount(
                          value.isEmpty ? null : double.tryParse(value),
                        );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _maxAmountController,
                  decoration: InputDecoration(
                    labelText: 'Max Amount',
                    prefixText: CurrencyHelper.getPrefixText(currency),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  onChanged: (value) {
                    ref.read(expenseFilterProvider.notifier).setMaxAmount(
                          value.isEmpty ? null : double.tryParse(value),
                        );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/constants/app_strings.dart';

/// Filter state for meal logs
class MealFilter {
  final String? mealType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  MealFilter({
    this.mealType,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  MealFilter copyWith({
    String? mealType,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    return MealFilter(
      mealType: mealType ?? this.mealType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasActiveFilters {
    return mealType != null ||
        startDate != null ||
        endDate != null ||
        (searchQuery != null && searchQuery!.isNotEmpty);
  }
}

/// Provider for meal filter
final mealFilterProvider = StateNotifierProvider<MealFilterNotifier, MealFilter>((ref) {
  return MealFilterNotifier();
});

class MealFilterNotifier extends StateNotifier<MealFilter> {
  MealFilterNotifier() : super(MealFilter());

  void setMealType(String? mealType) {
    state = state.copyWith(mealType: mealType);
  }

  void setStartDate(DateTime? date) {
    state = state.copyWith(startDate: date);
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: date);
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearFilters() {
    state = MealFilter();
  }
}

/// Filter bottom sheet widget
class MealFilterWidget extends ConsumerStatefulWidget {
  const MealFilterWidget({super.key});

  @override
  ConsumerState<MealFilterWidget> createState() => _MealFilterWidgetState();
}

class _MealFilterWidgetState extends ConsumerState<MealFilterWidget> {
  final _searchController = TextEditingController();
  final List<String> _mealTypes = [
    AppStrings.breakfast,
    AppStrings.lunch,
    AppStrings.dinner,
    AppStrings.snack,
  ];
  bool _controllersInitialized = false;

  void _syncControllersWithFilter(MealFilter filter) {
    if (!_controllersInitialized) {
      _searchController.text = filter.searchQuery ?? '';
      _controllersInitialized = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(mealFilterProvider);
    
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
                    ref.read(mealFilterProvider.notifier).clearFilters();
                    _searchController.clear();
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
              labelText: 'Search by notes',
              hintText: 'Enter keywords...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(mealFilterProvider.notifier).setSearchQuery(null);
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              ref.read(mealFilterProvider.notifier).setSearchQuery(
                    value.isEmpty ? null : value,
                  );
            },
          ),
          const SizedBox(height: 16),

          // Meal type filter
          Text(
            'Meal Type',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: filter.mealType == null,
                onSelected: (selected) {
                  ref.read(mealFilterProvider.notifier).setMealType(null);
                },
              ),
              ..._mealTypes.map((type) {
                final isSelected = filter.mealType == type;
                return FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    ref.read(mealFilterProvider.notifier).setMealType(
                          selected ? type : null,
                        );
                  },
                );
              }),
            ],
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
                      ref.read(mealFilterProvider.notifier).setStartDate(date);
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
                      ref.read(mealFilterProvider.notifier).setEndDate(date);
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_helper.dart';

/// Filter state for water logs
class WaterFilter {
  final DateTime? startDate;
  final DateTime? endDate;

  WaterFilter({
    this.startDate,
    this.endDate,
  });

  WaterFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return WaterFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  bool get hasActiveFilters {
    return startDate != null || endDate != null;
  }
}

/// Provider for water filter
final waterFilterProvider = StateNotifierProvider<WaterFilterNotifier, WaterFilter>((ref) {
  return WaterFilterNotifier();
});

class WaterFilterNotifier extends StateNotifier<WaterFilter> {
  WaterFilterNotifier() : super(WaterFilter());

  void setStartDate(DateTime? date) {
    state = state.copyWith(startDate: date);
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: date);
  }

  void clearFilters() {
    state = WaterFilter();
  }
}

/// Filter bottom sheet widget
class WaterFilterWidget extends ConsumerWidget {
  const WaterFilterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(waterFilterProvider);

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
                'Filter by Date',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (filter.hasActiveFilters)
                TextButton(
                  onPressed: () {
                    ref.read(waterFilterProvider.notifier).clearFilters();
                  },
                  child: const Text('Clear All'),
                ),
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
                      ref.read(waterFilterProvider.notifier).setStartDate(date);
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
                      ref.read(waterFilterProvider.notifier).setEndDate(date);
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

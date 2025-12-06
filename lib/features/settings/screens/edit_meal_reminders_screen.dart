import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../data/models/notification_schedule.dart';
import '../../../services/preferences_service.dart';
import '../../../services/notification_service.dart';

/// Screen for editing meal reminder schedules
class EditMealRemindersScreen extends StatefulWidget {
  const EditMealRemindersScreen({super.key});

  @override
  State<EditMealRemindersScreen> createState() => _EditMealRemindersScreenState();
}

class _EditMealRemindersScreenState extends State<EditMealRemindersScreen> {
  List<NotificationSchedule> _schedules = [];
  bool _isLoading = true;

  final List<String> _mealTypes = [
    AppStrings.breakfast,
    AppStrings.lunch,
    AppStrings.dinner,
    AppStrings.snack,
  ];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final schedules = await PreferencesService.getMealReminderSchedules();
    setState(() {
      _schedules = schedules;
      _isLoading = false;
    });
  }

  Future<void> _saveSchedules() async {
    await PreferencesService.setMealReminderSchedules(_schedules);
    
    // Reschedule all meal reminders
    await NotificationService.instance.cancelMealReminders();
    final enabled = await PreferencesService.getMealRemindersEnabled();
    if (enabled) {
      for (final schedule in _schedules) {
        if (schedule.mealType != null) {
          await NotificationService.instance.scheduleMealReminder(
            hour: schedule.hour,
            minute: schedule.minute,
            mealType: schedule.mealType!,
          );
        }
      }
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal reminders updated')),
      );
    }
  }

  void _addSchedule() {
    setState(() {
      _schedules.add(NotificationSchedule(
        hour: 8,
        minute: 0,
        mealType: AppStrings.breakfast,
      ));
    });
  }

  void _removeSchedule(int index) {
    setState(() {
      _schedules.removeAt(index);
    });
  }

  Future<void> _editSchedule(int index) async {
    final schedule = _schedules[index];
    
    // Show dialog to edit time and meal type
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _EditMealReminderDialog(
        schedule: schedule,
        mealTypes: _mealTypes,
      ),
    );

    if (result != null) {
      setState(() {
        _schedules[index] = NotificationSchedule(
          hour: result['hour'] as int,
          minute: result['minute'] as int,
          mealType: result['mealType'] as String,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Meal Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addSchedule,
            tooltip: 'Add reminder',
          ),
        ],
      ),
      body: Column(
        children: [
          // Schedules List
          Expanded(
            child: _schedules.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No reminders scheduled',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _addSchedule,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Reminder'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = _schedules[index];
                      final time = TimeOfDay(hour: schedule.hour, minute: schedule.minute);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.mealGradient.colors.first.withOpacity(0.1),
                            child: Icon(
                              Icons.restaurant,
                              color: AppColors.mealGradient.colors.first,
                            ),
                          ),
                          title: Text(
                            schedule.mealType ?? 'Meal',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            time.format(context),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editSchedule(index),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.error),
                                onPressed: () {
                                  if (_schedules.length > 1) {
                                    _removeSchedule(index);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('At least one reminder is required'),
                                      ),
                                    );
                                  }
                                },
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Save Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSchedules,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Changes'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditMealReminderDialog extends StatefulWidget {
  final NotificationSchedule schedule;
  final List<String> mealTypes;

  const _EditMealReminderDialog({
    required this.schedule,
    required this.mealTypes,
  });

  @override
  State<_EditMealReminderDialog> createState() => _EditMealReminderDialogState();
}

class _EditMealReminderDialogState extends State<_EditMealReminderDialog> {
  late TimeOfDay _selectedTime;
  late String _selectedMealType;

  @override
  void initState() {
    super.initState();
    _selectedTime = TimeOfDay(hour: widget.schedule.hour, minute: widget.schedule.minute);
    _selectedMealType = widget.schedule.mealType ?? AppStrings.breakfast;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Meal Reminder'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time Picker
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Time'),
            subtitle: Text(_selectedTime.format(context)),
            trailing: const Icon(Icons.chevron_right),
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
          const Divider(),
          // Meal Type Picker
          ListTile(
            leading: const Icon(Icons.restaurant),
            title: const Text('Meal Type'),
            subtitle: Text(_selectedMealType),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Meal Type'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.mealTypes.map((type) {
                      return RadioListTile<String>(
                        title: Text(type),
                        value: type,
                        groupValue: _selectedMealType,
                        onChanged: (value) {
                          setState(() {
                            _selectedMealType = value!;
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'hour': _selectedTime.hour,
              'minute': _selectedTime.minute,
              'mealType': _selectedMealType,
            });
          },
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}

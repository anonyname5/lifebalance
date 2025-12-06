import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../data/models/notification_schedule.dart';
import '../../../services/preferences_service.dart';
import '../../../services/notification_service.dart';

/// Screen for editing water reminder schedules
class EditWaterRemindersScreen extends StatefulWidget {
  const EditWaterRemindersScreen({super.key});

  @override
  State<EditWaterRemindersScreen> createState() => _EditWaterRemindersScreenState();
}

class _EditWaterRemindersScreenState extends State<EditWaterRemindersScreen> {
  List<NotificationSchedule> _schedules = [];
  String _message = "Time for water! 💧 Don't forget to stay hydrated.";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final schedules = await PreferencesService.getWaterReminderSchedules();
    final message = await PreferencesService.getWaterReminderMessage();
    setState(() {
      _schedules = schedules;
      _message = message;
      _isLoading = false;
    });
  }

  Future<void> _saveSchedules() async {
    await PreferencesService.setWaterReminderSchedules(_schedules);
    await PreferencesService.setWaterReminderMessage(_message);
    
    // Reschedule all water reminders
    await NotificationService.instance.cancelWaterReminders();
    final enabled = await PreferencesService.getWaterRemindersEnabled();
    if (enabled) {
      for (final schedule in _schedules) {
        await NotificationService.instance.scheduleWaterReminder(
          hour: schedule.hour,
          minute: schedule.minute,
          message: schedule.message ?? _message,
        );
      }
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Water reminders updated')),
      );
    }
  }

  void _addSchedule() {
    setState(() {
      _schedules.add(NotificationSchedule(
        hour: 8,
        minute: 0,
        message: _message,
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
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: schedule.hour, minute: schedule.minute),
    );

    if (time != null) {
      setState(() {
        _schedules[index] = schedule.copyWith(
          hour: time.hour,
          minute: time.minute,
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
        title: const Text('Edit Water Reminders'),
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
          // Message Editor
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reminder Message',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: TextEditingController(text: _message),
                    decoration: const InputDecoration(
                      hintText: 'Enter reminder message',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onChanged: (value) {
                      _message = value;
                    },
                  ),
                ],
              ),
            ),
          ),

          // Schedules List
          Expanded(
            child: _schedules.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = _schedules[index];
                      final time = TimeOfDay(hour: schedule.hour, minute: schedule.minute);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.info.withOpacity(0.1),
                            child: const Icon(Icons.water_drop, color: AppColors.info),
                          ),
                          title: Text(
                            'Reminder ${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${time.format(context)}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editSchedule(index),
                                tooltip: 'Edit time',
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../services/preferences_service.dart';
import '../../../services/notification_service.dart';

/// Notifications screen showing notification status and settings
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _notificationsEnabled = true;
  bool _waterRemindersEnabled = true;
  bool _mealRemindersEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final notifications = await PreferencesService.getNotificationsEnabled();
    final waterReminders = await PreferencesService.getWaterRemindersEnabled();
    final mealReminders = await PreferencesService.getMealRemindersEnabled();

    setState(() {
      _notificationsEnabled = notifications;
      _waterRemindersEnabled = waterReminders;
      _mealRemindersEnabled = mealReminders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                        color: _notificationsEnabled ? AppColors.success : AppColors.textSecondary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _notificationsEnabled ? 'Notifications Active' : 'Notifications Disabled',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _notificationsEnabled
                                  ? 'You will receive reminders and alerts'
                                  : 'Enable notifications to get reminders',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Notification Types
          Text(
            'Notification Types',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Water Reminders
          _buildNotificationTypeCard(
            context,
            icon: Icons.water_drop,
            title: 'Water Reminders',
            description: 'Get reminded to drink water every 2 hours from 8 AM to 6 PM',
            enabled: _waterRemindersEnabled,
            gradient: AppColors.waterGradient,
            onToggle: (value) async {
              await PreferencesService.setWaterRemindersEnabled(value);
              if (value) {
                // Schedule water reminders
                for (int hour = 8; hour <= 18; hour += 2) {
                  await NotificationService.instance.scheduleWaterReminder(
                    hour: hour,
                    minute: 0,
                    message: "Time for water! 💧 Don't forget to stay hydrated.",
                  );
                }
              } else {
                await NotificationService.instance.cancelWaterReminders();
              }
              setState(() {
                _waterRemindersEnabled = value;
              });
            },
          ),
          const SizedBox(height: 12),

          // Meal Reminders
          _buildNotificationTypeCard(
            context,
            icon: Icons.restaurant,
            title: 'Meal Reminders',
            description: 'Get reminded to log your meals (Breakfast: 8 AM, Lunch: 1 PM, Dinner: 7 PM)',
            enabled: _mealRemindersEnabled,
            gradient: AppColors.mealGradient,
            onToggle: (value) async {
              await PreferencesService.setMealRemindersEnabled(value);
              if (value) {
                // Schedule meal reminders
                await NotificationService.instance.scheduleMealReminder(
                  hour: 8,
                  minute: 0,
                  mealType: 'Breakfast',
                );
                await NotificationService.instance.scheduleMealReminder(
                  hour: 13,
                  minute: 0,
                  mealType: 'Lunch',
                );
                await NotificationService.instance.scheduleMealReminder(
                  hour: 19,
                  minute: 0,
                  mealType: 'Dinner',
                );
              } else {
                await NotificationService.instance.cancelMealReminders();
              }
              setState(() {
                _mealRemindersEnabled = value;
              });
            },
          ),
          const SizedBox(height: 12),

          // Budget Alerts
          _buildNotificationTypeCard(
            context,
            icon: Icons.account_balance_wallet,
            title: 'Budget Alerts',
            description: 'Get notified when you reach 80% or exceed your budget limits',
            enabled: _notificationsEnabled,
            gradient: AppColors.financeGradient,
            onToggle: null, // Controlled by main notifications toggle
          ),
          const SizedBox(height: 24),

          // Settings Section
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: const Text('Enable Notifications'),
              subtitle: const Text('Turn on/off all notifications'),
              value: _notificationsEnabled,
              onChanged: (value) async {
                await PreferencesService.setNotificationsEnabled(value);
                if (!value) {
                  // Cancel all notifications if disabled
                  await NotificationService.instance.cancelAll();
                  setState(() {
                    _waterRemindersEnabled = false;
                    _mealRemindersEnabled = false;
                  });
                }
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          // Information Card
          Card(
            color: AppColors.info.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About Notifications',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.info,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'All notifications are scheduled locally on your device. They will only work if you grant notification permissions to the app.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool enabled,
    required LinearGradient gradient,
    required Function(bool)? onToggle,
  }) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: enabled ? gradient : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: enabled
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: enabled ? Colors.white : AppColors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: enabled ? Colors.white : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: enabled
                                ? Colors.white.withOpacity(0.9)
                                : AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (onToggle != null)
                Switch(
                  value: enabled && _notificationsEnabled,
                  onChanged: _notificationsEnabled ? onToggle : null,
                  activeColor: enabled ? Colors.white : AppColors.primary,
                )
              else
                Icon(
                  enabled ? Icons.check_circle : Icons.info_outline,
                  color: enabled ? Colors.white : AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

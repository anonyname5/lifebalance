import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../services/preferences_service.dart';

/// Service for managing local notifications
class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  /// Initialize notifications
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to specific screen
    print('Notification tapped: ${response.payload}');
  }

  /// Schedule water reminder
  Future<void> scheduleWaterReminder({
    required int hour,
    required int minute,
    required String message,
  }) async {
    final enabled = await PreferencesService.getWaterRemindersEnabled();
    if (!enabled) return;

    // Use unique ID based on hour and minute to prevent conflicts
    // Format: 1000 + (hour * 60 + minute) to ensure uniqueness
    final notificationId = 1000 + (hour * 60 + minute);

    await _notifications.zonedSchedule(
      notificationId,
      'Water Reminder 💧',
      message,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminders',
          'Water Reminders',
          channelDescription: 'Reminders to drink water',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule meal reminder
  Future<void> scheduleMealReminder({
    required int hour,
    required int minute,
    required String mealType,
  }) async {
    final enabled = await PreferencesService.getMealRemindersEnabled();
    if (!enabled) return;

    // Use unique ID based on hour, minute, and meal type to prevent conflicts
    // Format: 2000 + (hour * 60 + minute) + (mealType hash % 100)
    final notificationId = 2000 + (hour * 60 + minute) + (mealType.hashCode % 100);

    await _notifications.zonedSchedule(
      notificationId,
      'Meal Reminder 🍽️',
      'Time for $mealType!',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_reminders',
          'Meal Reminders',
          channelDescription: 'Reminders to log meals',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Cancel water reminders
  Future<void> cancelWaterReminders() async {
    // Get current schedules and cancel them
    final schedules = await PreferencesService.getWaterReminderSchedules();
    for (final schedule in schedules) {
      final notificationId = 1000 + (schedule.hour * 60 + schedule.minute);
      await _notifications.cancel(notificationId);
    }
    // Also cancel default schedule IDs for backward compatibility
    for (int hour = 8; hour <= 18; hour += 2) {
      await _notifications.cancel(1000 + hour);
    }
  }

  /// Cancel meal reminders
  Future<void> cancelMealReminders() async {
    // Get current schedules and cancel them
    final schedules = await PreferencesService.getMealReminderSchedules();
    for (final schedule in schedules) {
      if (schedule.mealType != null) {
        final notificationId = 2000 + (schedule.hour * 60 + schedule.minute) + (schedule.mealType!.hashCode % 100);
        await _notifications.cancel(notificationId);
      }
    }
    // Also cancel default schedule IDs for backward compatibility
    await _notifications.cancel(2000 + 8);
    await _notifications.cancel(2000 + 13);
    await _notifications.cancel(2000 + 19);
  }

  /// Schedule all water reminders from saved schedules
  Future<void> scheduleAllWaterReminders() async {
    final enabled = await PreferencesService.getWaterRemindersEnabled();
    if (!enabled) return;

    final schedules = await PreferencesService.getWaterReminderSchedules();
    final defaultMessage = await PreferencesService.getWaterReminderMessage();

    for (final schedule in schedules) {
      await scheduleWaterReminder(
        hour: schedule.hour,
        minute: schedule.minute,
        message: schedule.message ?? defaultMessage,
      );
    }
  }

  /// Schedule all meal reminders from saved schedules
  Future<void> scheduleAllMealReminders() async {
    final enabled = await PreferencesService.getMealRemindersEnabled();
    if (!enabled) return;

    final schedules = await PreferencesService.getMealReminderSchedules();

    for (final schedule in schedules) {
      if (schedule.mealType != null) {
        await scheduleMealReminder(
          hour: schedule.hour,
          minute: schedule.minute,
          mealType: schedule.mealType!,
        );
      }
    }
  }

  /// Schedule budget alert notification
  Future<void> scheduleBudgetAlert({
    required String categoryName,
    required double spent,
    required double limit,
    required double percentage,
  }) async {
    final enabled = await PreferencesService.getNotificationsEnabled();
    if (!enabled) return;

    String message;
    if (percentage >= 100) {
      message = 'Budget exceeded for $categoryName! You\'ve spent RM${spent.toStringAsFixed(2)} of RM${limit.toStringAsFixed(2)}';
    } else if (percentage >= 80) {
      message = 'Warning: $categoryName budget is ${percentage.toStringAsFixed(0)}% used (RM${spent.toStringAsFixed(2)} / RM${limit.toStringAsFixed(2)})';
    } else {
      return; // Don't send notification if under 80%
    }

    await _notifications.show(
      100 + categoryName.hashCode % 1000, // Unique ID based on category
      'Budget Alert 💰',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'Budget Alerts',
          channelDescription: 'Notifications for budget warnings',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Check and send budget alerts for all categories
  Future<void> checkBudgetAlerts() async {
    // This will be called from a service that monitors budget progress
    // Implementation will be in a separate budget monitoring service
  }

  /// Show immediate notification (for testing)
  Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general',
          'General',
          channelDescription: 'General notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Get next instance of time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}

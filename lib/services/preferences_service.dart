import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/currency_helper.dart';
import '../data/models/notification_schedule.dart';

/// Service for managing app preferences
class PreferencesService {
  static const String _keyWaterGoal = 'water_goal';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyWaterRemindersEnabled = 'water_reminders_enabled';
  static const String _keyMealRemindersEnabled = 'meal_reminders_enabled';
  static const String _keyUserName = 'user_name';
  static const String _keyMonthlyIncome = 'monthly_income';
  static const String _keyCurrency = 'currency';
  static const String _keyThemeMode = 'theme_mode'; // 'light', 'dark', 'system'
  static const String _keyWaterReminderSchedules = 'water_reminder_schedules';
  static const String _keyMealReminderSchedules = 'meal_reminder_schedules';
  static const String _keyWaterReminderMessage = 'water_reminder_message';

  /// Get water goal (default: 8)
  static Future<int> getWaterGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyWaterGoal) ?? 8;
  }

  /// Set water goal
  static Future<bool> setWaterGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(_keyWaterGoal, goal);
  }

  /// Get notifications enabled status
  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  /// Set notifications enabled status
  static Future<bool> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  /// Get water reminders enabled status
  static Future<bool> getWaterRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyWaterRemindersEnabled) ?? true;
  }

  /// Set water reminders enabled status
  static Future<bool> setWaterRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_keyWaterRemindersEnabled, enabled);
  }

  /// Get meal reminders enabled status
  static Future<bool> getMealRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyMealRemindersEnabled) ?? false;
  }

  /// Set meal reminders enabled status
  static Future<bool> setMealRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_keyMealRemindersEnabled, enabled);
  }

  /// Get user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  /// Set user name
  static Future<bool> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyUserName, name);
  }

  /// Get monthly income
  static Future<double?> getMonthlyIncome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyMonthlyIncome);
  }

  /// Set monthly income
  static Future<bool> setMonthlyIncome(double income) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setDouble(_keyMonthlyIncome, income);
  }

  /// Get currency (default: USD)
  static Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrency) ?? CurrencyHelper.usd;
  }

  /// Set currency
  static Future<bool> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyCurrency, currency);
  }

  /// Get theme mode (default: 'light')
  static Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode) ?? 'light';
  }

  /// Set theme mode
  static Future<bool> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyThemeMode, mode);
  }

  /// Get water reminder schedules
  static Future<List<NotificationSchedule>> getWaterReminderSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyWaterReminderSchedules);
    if (jsonString == null) {
      // Return default schedule (every 2 hours from 8 AM to 6 PM)
      return [
        for (int hour = 8; hour <= 18; hour += 2)
          NotificationSchedule(
            hour: hour,
            minute: 0,
            message: "Time for water! 💧 Don't forget to stay hydrated.",
          ),
      ];
    }
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => NotificationSchedule.fromMap(json as Map<String, dynamic>)).toList();
  }

  /// Set water reminder schedules
  static Future<bool> setWaterReminderSchedules(List<NotificationSchedule> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = schedules.map((s) => s.toMap()).toList();
    final jsonString = json.encode(jsonList);
    return await prefs.setString(_keyWaterReminderSchedules, jsonString);
  }

  /// Get meal reminder schedules
  static Future<List<NotificationSchedule>> getMealReminderSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyMealReminderSchedules);
    if (jsonString == null) {
      // Return default schedule
      return [
        NotificationSchedule(hour: 8, minute: 0, mealType: 'Breakfast'),
        NotificationSchedule(hour: 13, minute: 0, mealType: 'Lunch'),
        NotificationSchedule(hour: 19, minute: 0, mealType: 'Dinner'),
      ];
    }
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => NotificationSchedule.fromMap(json as Map<String, dynamic>)).toList();
  }

  /// Set meal reminder schedules
  static Future<bool> setMealReminderSchedules(List<NotificationSchedule> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = schedules.map((s) => s.toMap()).toList();
    final jsonString = json.encode(jsonList);
    return await prefs.setString(_keyMealReminderSchedules, jsonString);
  }

  /// Get water reminder message
  static Future<String> getWaterReminderMessage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyWaterReminderMessage) ?? "Time for water! 💧 Don't forget to stay hydrated.";
  }

  /// Set water reminder message
  static Future<bool> setWaterReminderMessage(String message) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyWaterReminderMessage, message);
  }

  /// Clear all preferences
  static Future<bool> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }
}

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/water_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../data/repositories/meal_repository.dart';
import '../core/utils/date_helper.dart';
import '../services/preferences_service.dart';
import '../core/utils/currency_helper.dart';

/// Service for managing home screen widgets
class WidgetService {
  static const MethodChannel _channel = MethodChannel('com.lifebalance.widget');
  static const String _widgetDataKey = 'widget_data';

  /// Update widget with current data
  static Future<void> updateWidget() async {
    try {
      final data = await _getWidgetData();
      await _saveWidgetData(data);
      await _channel.invokeMethod('updateWidget', data);
    } catch (e) {
      // Widget might not be available, silently fail
      print('Widget update error (this is normal if widget is not added): $e');
    }
  }

  /// Get widget data from repositories
  static Future<Map<String, dynamic>> _getWidgetData() async {
    final today = DateHelper.todayAsString();
    final waterRepository = WaterRepository();
    final expenseRepository = ExpenseRepository();
    final mealRepository = MealRepository();

    // Get water intake
    final waterGoal = await PreferencesService.getWaterGoal();
    final totalGlasses = await waterRepository.getTotalGlassesByDate(today);
    final waterProgress = waterGoal > 0 ? (totalGlasses / waterGoal).clamp(0.0, 1.0) : 0.0;

    // Get today's spending
    final todayTotal = await expenseRepository.getTodayTotalExpenses();
    final currency = await PreferencesService.getCurrency();
    // Extract symbol from formatted amount
    final formatted = CurrencyHelper.formatAmount(0, currency);
    final currencySymbol = formatted.replaceAll(RegExp(r'[\d.,\s]'), '');

    // Get meal count
    final mealLogs = await mealRepository.getMealLogsByDate(today);
    final mealCount = mealLogs.length;

    // Get current month spending
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final monthTotal = await expenseRepository.getExpensesByDateRange(
      DateHelper.formatDateForDb(firstDay),
      DateHelper.formatDateForDb(lastDay),
    );
    final monthSpending = monthTotal.fold(0.0, (sum, expense) => sum + expense.amount);

    return {
      'waterGlasses': totalGlasses,
      'waterGoal': waterGoal,
      'waterProgress': waterProgress,
      'todaySpending': todayTotal,
      'monthSpending': monthSpending,
      'mealCount': mealCount,
      'currencySymbol': currencySymbol,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  /// Save widget data to SharedPreferences
  static Future<void> _saveWidgetData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    // Flutter SharedPreferences automatically adds "flutter." prefix
    await prefs.setString(_widgetDataKey, json.encode(data));
  }

  /// Get saved widget data
  static Future<Map<String, dynamic>?> getSavedWidgetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString(_widgetDataKey);
      if (dataString != null) {
        return json.decode(dataString) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error getting saved widget data: $e');
    }
    return null;
  }
}

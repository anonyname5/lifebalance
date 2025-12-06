import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'core/constants/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/screens/splash_screen.dart';
import 'features/settings/providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'services/recurring_expense_service.dart';

/// Main app widget
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize timezone
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('America/New_York')); // Default, can be changed
    } catch (e) {
      // Fallback to UTC if location not found
      tz.setLocalLocation(tz.UTC);
    }

    // Initialize notifications
    await NotificationService.instance.initialize();

    // Reschedule notifications if enabled
    await NotificationService.instance.scheduleAllWaterReminders();
    await NotificationService.instance.scheduleAllMealReminders();

    // Check and auto-log recurring expenses
    final recurringService = RecurringExpenseService();
    await recurringService.checkAndLogRecurringExpenses();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}

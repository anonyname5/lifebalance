import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../services/preferences_service.dart';
import '../../../services/notification_service.dart';
import '../../../services/export_service.dart';
import '../../../services/data_cleanup_service.dart';
import '../../../core/utils/currency_helper.dart';
import '../providers/theme_provider.dart';
import '../providers/currency_provider.dart';
import '../../finance/screens/expense_categories_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:io';
import 'profile_screen.dart';
import 'privacy_policy_screen.dart';

/// Settings screen
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _waterGoal = 8;
  bool _notificationsEnabled = true;
  bool _waterRemindersEnabled = true;
  bool _mealRemindersEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final goal = await PreferencesService.getWaterGoal();
    final notifications = await PreferencesService.getNotificationsEnabled();
    final waterReminders = await PreferencesService.getWaterRemindersEnabled();
    final mealReminders = await PreferencesService.getMealRemindersEnabled();

    setState(() {
      _waterGoal = goal;
      _notificationsEnabled = notifications;
      _waterRemindersEnabled = waterReminders;
      _mealRemindersEnabled = mealReminders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        children: [
          // Profile Section
          _buildSectionHeader('Profile'),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(AppStrings.profile),
            subtitle: const Text('Manage your profile information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                PageTransitions.slideRoute(
                  const ProfileScreen(),
                ),
              );
            },
          ),
          const Divider(),

          // Goals Section
          _buildSectionHeader('Goals'),
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Water Goal'),
            subtitle: const Text('Set your daily water intake goal'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showWaterGoalDialog(context);
            },
          ),
          const Divider(),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text(AppStrings.notifications),
            subtitle: const Text('Enable reminders and alerts'),
            value: _notificationsEnabled,
            onChanged: (value) async {
              await PreferencesService.setNotificationsEnabled(value);
              if (!value) {
                // Cancel all notifications if disabled
                await NotificationService.instance.cancelAll();
              }
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.water_drop),
            title: const Text('Water Reminders'),
            subtitle: const Text('Get reminded to drink water'),
            trailing: Switch(
              value: _waterRemindersEnabled,
              onChanged: (value) async {
                await PreferencesService.setWaterRemindersEnabled(value);
                if (value) {
                  // Schedule water reminders (every 2 hours from 8 AM to 6 PM)
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
          ),
          ListTile(
            leading: const Icon(Icons.restaurant),
            title: const Text('Meal Reminders'),
            subtitle: const Text('Get reminded to log meals'),
            trailing: Switch(
              value: _mealRemindersEnabled,
              onChanged: (value) async {
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
          ),
          const Divider(),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          Consumer(
            builder: (context, ref, child) {
              final themeMode = ref.watch(themeModeProvider);
              return ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Theme'),
                subtitle: Text(_getThemeModeText(themeMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showThemeDialog(context, ref);
                },
              );
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              final currency = ref.watch(currencyProvider);
              return ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Currency'),
                subtitle: Text(CurrencyHelper.getCurrencyName(currency)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showCurrencyDialog(context, ref);
                },
              );
            },
          ),
          const Divider(),

          // Categories Section
          _buildSectionHeader('Categories'),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Expense Categories'),
            subtitle: const Text('Manage custom expense categories'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                PageTransitions.slideRoute(
                  const ExpenseCategoriesScreen(),
                ),
              );
            },
          ),
          const Divider(),

          // Data Section
          _buildSectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Export your data as CSV or PDF'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showExportDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.error),
            title: const Text(
              'Delete All Data',
              style: TextStyle(color: AppColors.error),
            ),
            subtitle: const Text('Permanently delete all your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showDeleteDataDialog(context);
            },
          ),
          const Divider(),

          // About Section
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Privacy Policy'),
            subtitle: const Text('View our privacy policy and data practices'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                PageTransitions.slideRoute(
                  const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : AppColors.textSecondary,
        ),
      ),
    );
  }

  void _showWaterGoalDialog(BuildContext context) {
    final controller = TextEditingController(text: _waterGoal.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Water Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Daily glasses',
            hintText: '8',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final goal = int.tryParse(controller.text);
              if (goal != null && goal > 0) {
                await PreferencesService.setWaterGoal(goal);
                setState(() {
                  _waterGoal = goal;
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Water goal updated')),
                  );
                }
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'Are you sure you want to delete all your data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAllData(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _exportData(context, format: 'csv');
            },
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _exportData(context, format: 'pdf');
            },
            child: const Text('PDF'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, {required String format}) async {
    try {
      if (!context.mounted) return;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final exportService = ExportService();
      File file;

      if (format == 'csv') {
        file = await exportService.exportToCSV();
      } else {
        file = await exportService.exportToPDF();
      }

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'LifeBalance Data Export',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported successfully as ${format.toUpperCase()}'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading if still open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteAllData(BuildContext context) async {
    try {
      // Show confirmation with data count
      final cleanupService = DataCleanupService();
      final totalCount = await cleanupService.getTotalRecordCount();

      if (!context.mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
            'This will permanently delete all your data ($totalCount records).\n\n'
            'This action cannot be undone. Are you absolutely sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Delete Everything'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Show loading
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Delete all data
      await cleanupService.deleteAllData();

      // Cancel all notifications
      await NotificationService.instance.cancelAll();

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading

      // Refresh providers
      // Note: In a real app, you'd want to invalidate all providers
      // For now, we'll just show a success message

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data has been deleted'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading if still open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentMode = ref.read(themeModeProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, WidgetRef ref) {
    final currentCurrency = ref.read(currencyProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('US Dollar (USD)'),
              subtitle: const Text('RM'),
              value: CurrencyHelper.usd,
              groupValue: currentCurrency,
              onChanged: (value) {
                if (value != null) {
                  ref.read(currencyProvider.notifier).setCurrency(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Currency updated')),
                  );
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Malaysian Ringgit (MYR)'),
              subtitle: const Text('RM'),
              value: CurrencyHelper.myr,
              groupValue: currentCurrency,
              onChanged: (value) {
                if (value != null) {
                  ref.read(currencyProvider.notifier).setCurrency(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Currency updated')),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

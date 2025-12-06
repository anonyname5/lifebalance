import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Privacy Policy screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.privacy_tip,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Privacy Policy',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last Updated: ${_getLastUpdatedDate()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Introduction
            _buildSection(
              context,
              'Introduction',
              'Welcome to ${AppStrings.appName}. We are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, and safeguard your data when you use our application.',
            ),

            // Information We Collect
            _buildSection(
              context,
              'Information We Collect',
              'We collect the following types of information:\n\n'
              '• Personal Information: Name, profile picture, monthly income, and water intake goals.\n'
              '• Health Data: Water intake logs, meal logs, and wellness scores.\n'
              '• Financial Data: Expense records, budget categories, savings goals, and recurring expenses.\n'
              '• Usage Data: App preferences, theme settings, and notification preferences.\n\n'
              'All data is stored locally on your device using SQLite database. We do not transmit or share your data with third parties.',
            ),

            // How We Use Your Information
            _buildSection(
              context,
              'How We Use Your Information',
              'We use the collected information to:\n\n'
              '• Provide core app functionality (tracking water, meals, and expenses)\n'
              '• Generate insights and analytics based on your data\n'
              '• Send you notifications and reminders (if enabled)\n'
              '• Personalize your app experience (themes, currency preferences)\n'
              '• Calculate wellness scores and achievements\n\n'
              'All processing is done locally on your device.',
            ),

            // Data Storage
            _buildSection(
              context,
              'Data Storage',
              'All your data is stored locally on your device:\n\n'
              '• Database: SQLite database stored on your device\n'
              '• Photos: Receipt photos and profile pictures stored in app-specific directories\n'
              '• Preferences: App settings stored using device preferences\n\n'
              'We do not use cloud storage or external servers. Your data never leaves your device unless you explicitly export it.',
            ),

            // Data Security
            _buildSection(
              context,
              'Data Security',
              'We implement the following security measures:\n\n'
              '• Local storage: All data is stored on your device\n'
              '• No network transmission: Your data is never sent over the internet\n'
              '• Device-level security: Your data is protected by your device\'s security features\n\n'
              'However, you are responsible for maintaining the security of your device.',
            ),

            // Data Export and Deletion
            _buildSection(
              context,
              'Data Export and Deletion',
              'You have full control over your data:\n\n'
              '• Export: You can export your data as CSV or PDF files through the Settings menu\n'
              '• Deletion: You can delete all your data at any time through the Settings menu\n'
              '• No backup: Since data is stored locally, uninstalling the app will delete all data\n\n'
              'We recommend exporting your data regularly if you want to keep a backup.',
            ),

            // Third-Party Services
            _buildSection(
              context,
              'Third-Party Services',
              '${AppStrings.appName} uses the following third-party services:\n\n'
              '• Flutter Framework: For app development (no data collection)\n'
              '• Local Notifications: For reminders and alerts (local only)\n'
              '• File System: For storing photos and exports (local only)\n\n'
              'These services do not collect or transmit your personal data.',
            ),

            // Children\'s Privacy
            _buildSection(
              context,
              'Children\'s Privacy',
              '${AppStrings.appName} is not intended for children under the age of 13. We do not knowingly collect personal information from children. If you are a parent or guardian and believe your child has provided us with personal information, please contact us.',
            ),

            // Changes to This Policy
            _buildSection(
              context,
              'Changes to This Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by updating the "Last Updated" date at the top of this policy. You are advised to review this Privacy Policy periodically for any changes.',
            ),

            // Contact Information
            _buildSection(
              context,
              'Contact Us',
              'If you have any questions about this Privacy Policy, please contact us through the app settings or your preferred method of communication.',
            ),

            const SizedBox(height: 32),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your privacy is important to us. All data remains on your device.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  String _getLastUpdatedDate() {
    // Return current date in a readable format
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

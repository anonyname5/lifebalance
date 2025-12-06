import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/currency_helper.dart';
import '../providers/currency_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../providers/user_profile_provider.dart';
import '../../../services/preferences_service.dart';
import '../../../services/profile_picture_service.dart';

/// Profile management screen
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _incomeController;
  late TextEditingController _waterGoalController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _incomeController = TextEditingController();
    _waterGoalController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _incomeController.dispose();
    _waterGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          TextButton(
            onPressed: () => _saveProfile(context),
            child: const Text(
              AppStrings.save,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          // Load existing values
          if (profile != null) {
            _nameController.text = profile.name ?? '';
            _incomeController.text = profile.monthlyIncome?.toStringAsFixed(2) ?? '';
            _waterGoalController.text = profile.waterGoal.toString();
          } else {
            // Load from preferences as fallback
            _loadFromPreferences();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              backgroundImage: profile?.profilePicturePath != null &&
                                      profile!.profilePicturePath!.isNotEmpty
                                  ? FileImage(File(profile.profilePicturePath!))
                                  : null,
                              child: profile?.profilePicturePath == null ||
                                      profile!.profilePicturePath!.isEmpty
                                  ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppColors.primary,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primary,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => _showImagePickerDialog(context, ref),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile?.name ?? 'User',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        if (profile?.profilePicturePath != null &&
                            profile!.profilePicturePath!.isNotEmpty)
                          TextButton.icon(
                            onPressed: () => _removeProfilePicture(context, ref),
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: const Text('Remove Photo'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter your name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Monthly Income Field
                  Consumer(
                    builder: (context, ref, child) {
                      final currency = ref.watch(currencyProvider);
                      return TextFormField(
                    controller: _incomeController,
                        decoration: InputDecoration(
                          labelText: CurrencyHelper.getLabelText('Monthly Income', currency),
                          prefixText: CurrencyHelper.getPrefixText(currency),
                          prefixIcon: const Icon(Icons.attach_money),
                          border: const OutlineInputBorder(),
                      helperText: 'Used for budget calculations',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Please enter a valid amount';
                        }
                      }
                      return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Water Goal Field
                  TextFormField(
                    controller: _waterGoalController,
                    decoration: const InputDecoration(
                      labelText: 'Daily Water Goal (glasses)',
                      prefixIcon: Icon(Icons.water_drop),
                      border: OutlineInputBorder(),
                      helperText: 'Recommended: 8 glasses per day',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a water goal';
                      }
                      if (int.tryParse(value) == null || int.parse(value) <= 0) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Info Card
                  Card(
                    color: AppColors.info.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.info),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your profile information is stored locally and kept private.',
                              style: TextStyle(color: AppColors.info),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading profile: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(userProfileNotifierProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadFromPreferences() async {
    final name = await PreferencesService.getUserName();
    final income = await PreferencesService.getMonthlyIncome();
    final waterGoal = await PreferencesService.getWaterGoal();

    if (mounted) {
      _nameController.text = name ?? '';
      _incomeController.text = income?.toStringAsFixed(2) ?? '';
      _waterGoalController.text = waterGoal.toString();
    }
  }

  Future<void> _saveProfile(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final notifier = ref.read(userProfileNotifierProvider.notifier);

    // Save name
    if (_nameController.text.isNotEmpty) {
      await notifier.updateName(_nameController.text);
      await PreferencesService.setUserName(_nameController.text);
    }

    // Save monthly income
    if (_incomeController.text.isNotEmpty) {
      final income = double.parse(_incomeController.text);
      await notifier.updateMonthlyIncome(income);
      await PreferencesService.setMonthlyIncome(income);
    }

    // Save water goal
    if (_waterGoalController.text.isNotEmpty) {
      final goal = int.parse(_waterGoalController.text);
      await notifier.updateWaterGoal(goal);
      await PreferencesService.setWaterGoal(goal);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _showImagePickerDialog(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Profile Picture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final path = await ProfilePictureService.instance.pickImageFromGallery();
                if (path != null && mounted) {
                  final notifier = ref.read(userProfileNotifierProvider.notifier);
                  await notifier.updateProfilePicturePath(path);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile picture updated')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final path = await ProfilePictureService.instance.pickImageFromCamera();
                if (path != null && mounted) {
                  final notifier = ref.read(userProfileNotifierProvider.notifier);
                  await notifier.updateProfilePicturePath(path);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile picture updated')),
                    );
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeProfilePicture(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Profile Picture'),
        content: const Text('Are you sure you want to remove your profile picture?'),
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
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final profileAsync = ref.read(userProfileNotifierProvider);
      final profile = profileAsync.valueOrNull;
      
      if (profile?.profilePicturePath != null) {
        await ProfilePictureService.instance.deleteProfilePicture(profile!.profilePicturePath);
      }

      final notifier = ref.read(userProfileNotifierProvider.notifier);
      await notifier.updateProfilePicturePath(null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture removed')),
        );
      }
    }
  }
}

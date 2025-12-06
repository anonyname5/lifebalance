import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/achievement.dart';
import '../providers/achievement_provider.dart';

/// Achievements screen
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsProvider);
    final progressAsync = ref.watch(achievementProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(achievementsProvider);
              ref.invalidate(achievementProgressProvider);
              // Check for new achievements
              final service = ref.read(achievementServiceProvider);
              service.checkAndUnlockAchievements().then((unlocked) {
                if (unlocked.isNotEmpty && context.mounted) {
                  ref.invalidate(achievementsProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🎉 ${unlocked.length} new achievement${unlocked.length > 1 ? 's' : ''} unlocked!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Card
          progressAsync.when(
            data: (progress) => Card(
              margin: const EdgeInsets.all(16),
              color: AppColors.primary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      '${progress['unlocked'] as int} / ${progress['total'] as int}',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Achievements Unlocked',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (progress['progress'] as double) / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress['progress'] as double).toStringAsFixed(1)}% Complete',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Achievements List
          Expanded(
            child: achievementsAsync.when(
              data: (achievements) {
                if (achievements.isEmpty) {
                  return Center(
                    child: Text(
                      'No achievements available',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  );
                }

                // Separate unlocked and locked
                final unlocked = achievements.where((a) => a.isUnlocked).toList();
                final locked = achievements.where((a) => !a.isUnlocked).toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (unlocked.isNotEmpty) ...[
                      Text(
                        'Unlocked',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ...unlocked.map((achievement) => _buildAchievementCard(
                            context,
                            achievement,
                            isUnlocked: true,
                          )),
                      const SizedBox(height: 24),
                    ],
                    if (locked.isNotEmpty) ...[
                      Text(
                        'Locked',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ...locked.map((achievement) => _buildAchievementCard(
                            context,
                            achievement,
                            isUnlocked: false,
                          )),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading achievements: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    Achievement achievement, {
    required bool isUnlocked,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isUnlocked
          ? AppColors.success.withOpacity(0.1)
          : Colors.grey[200]?.withOpacity(0.3),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isUnlocked
                ? AppColors.success.withOpacity(0.2)
                : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              achievement.icon,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        title: Text(
          achievement.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUnlocked ? AppColors.textPrimary : Colors.grey[600],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              achievement.description,
              style: TextStyle(
                color: isUnlocked ? AppColors.textSecondary : Colors.grey[500],
              ),
            ),
            if (achievement.unlockedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Unlocked: ${_formatDate(achievement.unlockedAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                      fontSize: 11,
                    ),
              ),
            ],
          ],
        ),
        trailing: isUnlocked
            ? Icon(Icons.check_circle, color: AppColors.success)
            : Icon(Icons.lock, color: Colors.grey[400]),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

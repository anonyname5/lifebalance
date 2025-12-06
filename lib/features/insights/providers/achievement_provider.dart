import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/achievement_service.dart';
import '../../../data/models/achievement.dart';

/// Achievement service provider
final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService();
});

/// All achievements provider
final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final service = ref.watch(achievementServiceProvider);
  return await service.loadAchievementsWithStatus();
});

/// Unlocked achievements provider
final unlockedAchievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final service = ref.watch(achievementServiceProvider);
  final allAchievements = await service.loadAchievementsWithStatus();
  return allAchievements.where((a) => a.isUnlocked).toList();
});

/// Achievement progress provider
final achievementProgressProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(achievementServiceProvider);
  final achievements = await service.loadAchievementsWithStatus();
  
  final total = achievements.length;
  final unlocked = achievements.where((a) => a.isUnlocked).length;
  final progress = total > 0 ? (unlocked / total * 100) : 0.0;

  return {
    'total': total,
    'unlocked': unlocked,
    'locked': total - unlocked,
    'progress': progress,
  };
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/user_profile_repository.dart';
import '../../../data/models/user_profile.dart';

/// User profile repository provider
final userProfileRepositoryProvider =
    Provider<UserProfileRepository>((ref) {
  return UserProfileRepository();
});

/// User profile provider
final userProfileProvider =
    FutureProvider<UserProfile?>((ref) async {
  final repository = ref.watch(userProfileRepositoryProvider);
  return await repository.getUserProfile();
});

/// User profile notifier
class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final UserProfileRepository _repository;

  UserProfileNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _repository.getUserProfile();
      state = AsyncValue.data(profile);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    try {
      await _repository.saveUserProfile(profile);
      await _loadProfile();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateName(String name) async {
    try {
      await _repository.updateUserName(name);
      await _loadProfile();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateMonthlyIncome(double income) async {
    try {
      await _repository.updateMonthlyIncome(income);
      await _loadProfile();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateWaterGoal(int goal) async {
    try {
      await _repository.updateWaterGoal(goal);
      await _loadProfile();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateProfilePicturePath(String? picturePath) async {
    try {
      await _repository.updateProfilePicturePath(picturePath);
      await _loadProfile();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

/// User profile notifier provider
final userProfileNotifierProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>(
  (ref) {
    final repository = ref.watch(userProfileRepositoryProvider);
    return UserProfileNotifier(repository);
  },
);

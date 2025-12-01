import 'package:budget_tracker/core/error/failures.dart';
import 'package:budget_tracker/core/error/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_hive_datasource.dart';

/// Implementation of UserProfileRepository using Hive data source
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileHiveDataSource _dataSource;

  UserProfileRepositoryImpl(this._dataSource);

  @override
  Future<Result<UserProfile?>> getUserProfile() async {
    return await _dataSource.getUserProfile();
  }

  @override
  Future<Result<void>> saveUserProfile(UserProfile profile) async {
    return await _dataSource.saveUserProfile(profile);
  }

  @override
  Future<Result<void>> updateUserProfile({
    String? name,
    String? email,
    String? avatarUrl,
  }) async {
    // First get the current profile
    final getResult = await getUserProfile();
    return getResult.when(
      success: (currentProfile) async {
        if (currentProfile == null) {
          return Result.error(Failure.notFound('User profile not found'));
        }

        // Update the profile with new values
        final updatedProfile = currentProfile.copyWith(
          name: name ?? currentProfile.name,
          email: email ?? currentProfile.email,
          avatarUrl: avatarUrl ?? currentProfile.avatarUrl,
          updatedAt: DateTime.now(),
        );

        return await saveUserProfile(updatedProfile);
      },
      error: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<bool>> hasCompletedOnboarding() async {
    return await _dataSource.hasCompletedOnboarding();
  }

  @override
  Future<Result<void>> clearUserProfile() async {
    return await _dataSource.clear();
  }
}
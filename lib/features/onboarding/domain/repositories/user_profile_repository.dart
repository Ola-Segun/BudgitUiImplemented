import 'package:budget_tracker/core/error/result.dart';
import '../entities/user_profile.dart';

/// Repository interface for user profile operations
abstract class UserProfileRepository {
  /// Get the current user profile
  Future<Result<UserProfile?>> getUserProfile();

  /// Save or update user profile
  Future<Result<void>> saveUserProfile(UserProfile profile);

  /// Update specific fields of the user profile
  Future<Result<void>> updateUserProfile({
    String? name,
    String? email,
    String? avatarUrl,
  });

  /// Check if user has completed onboarding
  Future<Result<bool>> hasCompletedOnboarding();

  /// Clear user profile data
  Future<Result<void>> clearUserProfile();
}
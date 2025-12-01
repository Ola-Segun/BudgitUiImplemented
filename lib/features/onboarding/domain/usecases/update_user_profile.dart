import 'package:budget_tracker/core/error/failures.dart';
import 'package:budget_tracker/core/error/result.dart';
import '../repositories/user_profile_repository.dart';

/// Use case for updating user profile
class UpdateUserProfile {
  final UserProfileRepository _repository;

  UpdateUserProfile(this._repository);

  /// Update user profile with new data
  Future<Result<void>> call({
    String? name,
    String? email,
    String? avatarUrl,
  }) async {
    // Basic validation
    if (name != null && name.trim().isEmpty) {
      return Result.error(Failure.validation('Name cannot be empty', {'name': 'Name cannot be empty'}));
    }

    if (email != null && email.trim().isEmpty) {
      return Result.error(Failure.validation('Email cannot be empty', {'email': 'Email cannot be empty'}));
    }

    if (email != null && !_isValidEmail(email)) {
      return Result.error(Failure.validation('Invalid email format', {'email': 'Invalid email format'}));
    }

    return await _repository.updateUserProfile(
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    );
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
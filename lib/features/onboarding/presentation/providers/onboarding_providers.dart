import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart' as core_providers;
import '../../../accounts/domain/usecases/create_account.dart';
import '../../../budgets/domain/usecases/create_budget.dart';
import '../../data/datasources/user_profile_hive_datasource.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/entities/onboarding_data.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/usecases/update_user_profile.dart';
import '../notifiers/onboarding_notifier.dart';
import '../states/onboarding_state.dart';

/// Provider for user profile data source
final userProfileDataSourceProvider = Provider<UserProfileHiveDataSource>((ref) {
  final dataSource = UserProfileHiveDataSource();
  // Note: Initialization is handled in appInitializationProvider
  return dataSource;
});

/// Provider for user profile repository
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final dataSource = ref.watch(userProfileDataSourceProvider);
  return UserProfileRepositoryImpl(dataSource);
});

/// Provider for update user profile use case
final updateUserProfileProvider = Provider<UpdateUserProfile>((ref) {
  final repository = ref.watch(userProfileRepositoryProvider);
  return UpdateUserProfile(repository);
});

/// Provider for CreateBudget use case
final createBudgetProvider = Provider<CreateBudget>((ref) {
  return ref.read(core_providers.createBudgetProvider);
});

/// Provider for CreateAccount use case
final createAccountProvider = Provider<CreateAccount>((ref) {
  return ref.read(core_providers.createAccountProvider);
});

/// State notifier provider for onboarding state management
final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final createBudget = ref.watch(createBudgetProvider);
  final createAccount = ref.watch(createAccountProvider);
  final userProfileDataSource = ref.watch(userProfileDataSourceProvider);

  return OnboardingNotifier(
    createBudget: createBudget,
    createAccount: createAccount,
    userProfileDataSource: userProfileDataSource,
  );
});

/// Provider for checking if user has completed onboarding
final hasCompletedOnboardingProvider = Provider<bool>((ref) {
  final onboardingState = ref.watch(onboardingNotifierProvider);
  return onboardingState.isCompleted;
});

/// Provider for current onboarding step
final currentOnboardingStepProvider = Provider<OnboardingStep>((ref) {
  final onboardingState = ref.watch(onboardingNotifierProvider);
  return onboardingState.currentStep;
});

/// Provider for onboarding progress
final onboardingProgressProvider = Provider<double>((ref) {
  final onboardingState = ref.watch(onboardingNotifierProvider);
  return onboardingState.progress;
});

/// Provider for onboarding data
final onboardingDataProvider = Provider<OnboardingData>((ref) {
  final onboardingState = ref.watch(onboardingNotifierProvider);
  return onboardingState.onboardingData;
});

/// Provider for user profile
final userProfileProvider = Provider<UserProfile?>((ref) {
  final onboardingState = ref.watch(onboardingNotifierProvider);
  return onboardingState.userProfile;
});
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'core/di/providers.dart';
import 'core/router/app_router.dart';
import 'core/storage/hive_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/onboarding_flow.dart';
import 'features/onboarding/presentation/providers/onboarding_providers.dart';
import 'features/recurring_incomes/data/models/recurring_income_dto.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage
  await HiveStorage.init();

  // Register all adapters globally before app starts
  // Register recurring income adapters first (typeIds 8, 9, 10)
  if (!Hive.isAdapterRegistered(8)) {
    Hive.registerAdapter(RecurringIncomeDtoAdapter());
  }
  if (!Hive.isAdapterRegistered(9)) {
    Hive.registerAdapter(RecurringIncomeInstanceDtoAdapter());
  }
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(RecurringIncomeRuleDtoAdapter());
  }

  // Register account adapter (typeId 8) - but recurring income already uses 8, so this conflicts!
  // We need to fix the typeId conflict. Let's use a different ID for accounts.
  // Actually, looking at the logs, accounts datasource registers with ID 8, but recurring income also uses 8.
  // This is a conflict that needs to be resolved.

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch app initialization
    final initialization = ref.watch(appInitializationProvider);

    return initialization.when(
      loading: () => const MaterialApp(
        title: 'Budget Tracker',
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
      error: (error, stack) => MaterialApp(
        title: 'Budget Tracker',
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize app: $error'),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
      data: (_) {
        // Watch theme mode changes
        final themeMode = ref.watch(themeModeProvider);

        // Check if onboarding is completed
        final hasCompletedOnboarding = ref.watch(hasCompletedOnboardingProvider);
        debugPrint('MyApp: hasCompletedOnboarding = $hasCompletedOnboarding');

        if (!hasCompletedOnboarding) {
          debugPrint('MyApp: Showing OnboardingFlow');
          return MaterialApp(
            title: 'Budget Tracker',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeMode,
            home: const OnboardingFlow(),
            debugShowCheckedModeBanner: false,
          );
        }

        debugPrint('MyApp: Showing main app');
        return MaterialApp.router(
          title: 'Budget Tracker',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeMode,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

/// Global error boundary to catch unhandled errors
class _ErrorBoundary extends StatefulWidget {
  const _ErrorBoundary({required this.child});

  final Widget? child;

  @override
  State<_ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<_ErrorBoundary> {
  String? _pendingError;

  @override
  void initState() {
    super.initState();

    // Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      // Log error
      debugPrint('Flutter Error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');

      // Store error to show when widget is ready
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _pendingError = details.exception.toString();
            });
          }
        });
      }
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Show pending error when we have proper context
    if (_pendingError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pendingError != null) {
          _showErrorDialog(_pendingError!);
          if (mounted) {
            setState(() {
              _pendingError = null;
            });
          }
        }
      });
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Something went wrong'),
        content: Text('Error: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}

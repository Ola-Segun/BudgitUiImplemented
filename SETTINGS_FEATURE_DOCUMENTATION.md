# Comprehensive Settings Feature Documentation

## Table of Contents

1. [Implementation Overview](#implementation-overview)
2. [Architecture Details](#architecture-details)
3. [Feature Documentation](#feature-documentation)
4. [API Documentation](#api-documentation)
5. [Integration Guide](#integration-guide)
6. [User Guide](#user-guide)
7. [Troubleshooting & FAQ](#troubleshooting--faq)
8. [Future Enhancement Roadmap](#future-enhancement-roadmap)

---

## Implementation Overview

The Settings feature is a comprehensive configuration system for the Budget Tracker application, providing users with extensive control over app behavior, appearance, security, and data management. The implementation follows clean architecture principles with clear separation of concerns across domain, data, and presentation layers.

### Key Characteristics

- **Modular Design**: Clean separation between UI, business logic, and data persistence
- **Reactive State Management**: Riverpod-based state management with real-time updates
- **Cross-Platform Support**: Full Android and iOS compatibility with platform-specific optimizations
- **Privacy-First Approach**: Built-in privacy controls and data protection features
- **Extensible Architecture**: Easy to add new settings categories and features
- **Comprehensive Testing**: Unit, integration, and UI testing coverage

### Core Components

#### Domain Layer
- **Entities**: `AppSettings`, `ImportResult`, `ImportError`, `SecurityEvent`
- **Services**: `FormattingService`, `PrivacyModeService`, `DataExportService`, `DataImportService`, `LocaleService`, `TwoFactorService`, `SecurityMonitoringService`
- **Use Cases**: Settings management, data import/export operations
- **Repositories**: Abstract interfaces for data access

#### Data Layer
- **Hive Integration**: Persistent storage with type-safe adapters
- **Repository Implementations**: Concrete data access implementations
- **Migration System**: Backward-compatible data schema updates

#### Presentation Layer
- **Riverpod Providers**: State management and dependency injection
- **Modern UI Components**: Custom widgets following design system
- **Accessibility Support**: Screen reader compatibility and touch target compliance
- **Animation System**: Smooth transitions and micro-interactions

---

## Architecture Details

### State Management Architecture

```dart
// Core Settings Provider Chain
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(HiveStorage());
});

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<SettingsState>>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

final currentSettingsProvider = Provider<AppSettings?>((ref) {
  final state = ref.watch(settingsNotifierProvider);
  return state.maybeWhen(
    data: (settingsState) => settingsState.settings,
    orElse: () => null,
  );
});
```

### Service Integration Pattern

```dart
class FormattingService {
  const FormattingService(this._ref);

  final Ref _ref;

  String get currencyCode => _ref.read(currentSettingsProvider)?.currencyCode ?? 'USD';
  String get dateFormat => _ref.read(currentSettingsProvider)?.dateFormat ?? 'MM/dd/yyyy';

  String formatCurrency(double amount, {String? currencyCode, int? decimalDigits}) {
    final code = currencyCode ?? this.currencyCode;
    final formatter = NumberFormat.currency(symbol: _getCurrencySymbol(code));
    return formatter.format(amount);
  }
}
```

### Data Flow Architecture

```
UI Layer (Widgets) ↔ Presentation Layer (Providers/Notifiers) ↔ Domain Layer (Use Cases/Services) ↔ Data Layer (Repositories) ↔ Storage (Hive)
```

### Security Architecture

- **Biometric Authentication**: Platform-specific biometric APIs integration
- **Two-Factor Authentication**: SMS/Email/Authenticator app support
- **Privacy Mode**: Real-time data obscuring with gesture activation
- **Activity Logging**: Comprehensive user action tracking
- **Data Encryption**: Secure storage of sensitive settings

---

## Feature Documentation

### Appearance Settings

**Purpose**: Customize the visual appearance of the application.

**Features**:
- **Theme Selection**: System/Light/Dark theme modes
- **Currency Selection**: Support for 10+ currencies with proper formatting
- **Date Format Selection**: Multiple date format options (MM/dd/yyyy, dd/MM/yyyy, yyyy-MM-dd)

**Usage**:
```dart
// Accessing appearance settings
final settings = ref.watch(currentSettingsProvider);
final themeMode = settings?.themeMode ?? ThemeMode.system;
final currency = settings?.currencyCode ?? 'USD';
final dateFormat = settings?.dateFormat ?? 'MM/dd/yyyy';
```

**Integration Points**:
- MaterialApp themeMode property
- FormattingService for currency display
- Date formatting throughout transaction displays

### Account Themes

**Purpose**: Customize visual themes for different account types.

**Features**:
- **Account Type Themes**: Custom colors and icons for checking, savings, credit cards, etc.
- **Theme Persistence**: Settings stored in Hive with AccountTypeTheme entities

### Notifications

**Purpose**: Comprehensive notification management system.

**Features**:
- **Push Notifications**: Firebase Cloud Messaging integration
- **Budget Alerts**: Configurable threshold-based alerts (50-100%)
- **Bill Reminders**: Advance notice (1-14 days before due date)
- **Income Reminders**: Notification for expected income (0-7 days before)
- **Platform Channels**: Android notification channels, iOS categories

### Security & Privacy

**Purpose**: Protect user data and provide authentication options.

**Features**:
- **Biometric Authentication**: Fingerprint/Face ID support
- **Auto Backup**: Automatic data backup to cloud
- **Two-Factor Authentication**: SMS/Email/Authenticator app methods

### Privacy Mode

**Purpose**: Temporarily obscure sensitive financial information.

**Features**:
- **Gesture Activation**: Three-finger double tap to toggle
- **Data Obscuring**: Amounts displayed as bullets (••••••)
- **Real-time Toggle**: Instant activation/deactivation

### Data Management

**Purpose**: Import/export application data for backup and migration.

**Features**:
- **Export Formats**: JSON, CSV, PDF (planned)
- **Import Validation**: Comprehensive error reporting with line numbers
- **Data Types**: Accounts, transactions, categories, budgets, goals, bills

### Language Support

**Purpose**: Multi-language application support.

**Features**:
- **10 Languages**: English, Spanish, French, German, Italian, Portuguese, Russian, Japanese, Korean, Chinese
- **Dynamic Switching**: App restart required for language changes

### Quiet Hours

**Purpose**: Prevent notifications during specified time periods.

**Features**:
- **Time Range Configuration**: Start and end times
- **Notification Filtering**: All notification types respect quiet hours

### Export Options

**Purpose**: Automated data export functionality.

**Features**:
- **Scheduled Exports**: Daily, weekly, monthly, quarterly intervals
- **Background Processing**: WorkManager integration for Android

### Advanced Settings

**Purpose**: Developer and power-user configuration options.

**Features**:
- **Activity Logging**: Track user actions for analytics
- **Performance Monitoring**: Memory and CPU usage tracking

### About Section

**Purpose**: Application information and legal links.

**Features**:
- **Version Information**: App version and build number
- **Legal Links**: Terms of Service and Privacy Policy

---

## API Documentation

### Core Services

#### FormattingService

**Purpose**: Centralized formatting for currencies and dates.

**Methods**:
```dart
class FormattingService {
  String formatCurrency(double amount, {String? currencyCode, int? decimalDigits});
  String formatDate(DateTime date, {String? format});
  String formatDateTime(DateTime dateTime, {String? dateFormat, String? timeFormat});
}
```

**Providers**:
```dart
final formattingServiceProvider = Provider<FormattingService>((ref) {
  return FormattingService(ref);
});
```

#### PrivacyModeService

**Purpose**: Manage privacy mode state and data obscuring.

**Methods**:
```dart
class PrivacyModeService {
  bool get isPrivacyModeEnabled;
  bool get isGestureEnabled;
  Future<void> togglePrivacyMode();
  Future<void> setPrivacyMode(bool enabled);
  bool shouldObscureSensitiveData();
  String obscureText(String text);
  String obscureAmount(double amount, String currency);
}
```

#### DataExportService

**Purpose**: Export application data in various formats.

**Methods**:
```dart
class DataExportService {
  Future<Result<String>> exportAllData({required DataExportType format});
}
```

#### DataImportService

**Purpose**: Import data from external sources with validation.

**Methods**:
```dart
class DataImportService {
  Future<Either<ImportError, ImportResult>> importFromFile(
    File file, {
    required ImportOptions options,
  });
}
```

### Repository Interfaces

#### SettingsRepository

**Purpose**: Abstract interface for settings data operations.

**Methods**:
```dart
abstract class SettingsRepository {
  Future<Result<AppSettings>> getSettings();
  Future<Result<void>> saveSettings(AppSettings settings);
  Future<Result<bool>> isBiometricAvailable();
  Future<Result<String>> getAppVersion();
  Future<Result<void>> clearAllData();
}
```

### Provider APIs

#### SettingsNotifier

**Purpose**: State management for settings operations.

**Methods**:
```dart
class SettingsNotifier extends StateNotifier<AsyncValue<SettingsState>> {
  Future<void> loadSettings();
  Future<void> updateSettings(AppSettings settings);
  Future<void> updateSetting(String key, dynamic value);
  Future<void> resetToDefaults();
}
```

---

## Integration Guide

### Adding New Settings

1. **Extend AppSettings Entity**:
```dart
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    // ... existing fields
    @Default(false) bool newFeatureEnabled,
    String? newFeatureConfig,
  }) = _AppSettings;
}
```

2. **Update Default Settings**:
```dart
factory AppSettings.defaultSettings() => AppSettings(
  // ... existing defaults
  newFeatureEnabled: false,
  newFeatureConfig: null,
);
```

3. **Add UI Components**:
```dart
// In settings screen
ModernToggleButton(
  options: ['Off', 'On'],
  selectedIndex: settings.newFeatureEnabled ? 1 : 0,
  onChanged: (index) => ref.read(settingsNotifierProvider.notifier)
      .updateSetting('newFeatureEnabled', index == 1),
),
```

### Integrating with Existing Features

#### Theme Integration
```dart
class ThemeIntegration {
  ThemeData getTheme(BuildContext context, AppSettings settings) {
    final baseTheme = settings.themeMode == ThemeMode.dark
        ? ThemeData.dark()
        : ThemeData.light();

    return baseTheme.copyWith(
      primaryColor: settings.accentColor,
    );
  }
}
```

#### Privacy Mode Integration
```dart
class PrivacyAwareWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacyMode = ref.watch(privacyModeServiceProvider);
    final amount = 1234.56;

    return Text(
      privacyMode.shouldObscureSensitiveData()
          ? privacyMode.obscureAmount(amount, 'USD')
          : '\$${amount.toStringAsFixed(2)}',
    );
  }
}
```

---

## User Guide

### Getting Started with Settings

1. **Access Settings**: Navigate to the "More" tab and tap "Settings"
2. **Browse Categories**: Scroll through organized sections
3. **Make Changes**: Tap on any setting to modify its value
4. **Save Automatically**: Changes are saved instantly

### Appearance Customization

#### Changing Theme
- Tap "Theme" under Appearance section
- Choose from System, Light, or Dark
- Changes apply immediately app-wide

#### Setting Currency
- Tap "Currency" to open currency selector
- Choose from supported currencies
- Affects all monetary displays

### Notification Management

#### Budget Alerts
- Enable/disable budget alerts
- Set alert threshold (50-100% of budget)
- Receive notifications when spending approaches limit

#### Quiet Hours
- Enable quiet hours to silence notifications
- Set start and end times
- All notifications respect quiet hours

### Security & Privacy

#### Biometric Authentication
- Enable fingerprint or face unlock
- Requires device biometric capability

#### Privacy Mode
- Activate privacy mode to hide sensitive data
- Use three-finger double tap gesture
- Amounts show as bullets when active

### Data Management

#### Exporting Data
- Tap "Export Data" to create backup
- Choose format (JSON recommended)
- File saved to device storage

#### Importing Data
- Tap "Import Data" to restore from backup
- Select file from device storage
- Review import results

---

## Troubleshooting & FAQ

### Common Issues

#### Settings Not Saving
**Problem**: Changes to settings don't persist after app restart.

**Solutions**:
1. Check available storage space
2. Clear app cache and restart
3. Reinstall app (data will be preserved)
4. Check for app updates

#### Notifications Not Working
**Problem**: Push notifications aren't being received.

**Solutions**:
1. Check notification permissions in device settings
2. Verify internet connection
3. Restart device
4. Check if app is in battery optimization

### FAQ

**Q: How do I backup my data?**
A: Use the "Export Data" feature in Data Management section. Choose JSON format for complete backup.

**Q: Can I use the app in multiple languages?**
A: Yes, the app supports 10 languages. Change language in Settings > Language (app restart required).

**Q: What happens during Privacy Mode?**
A: Sensitive financial information is obscured with bullet characters. Use three-finger double tap to toggle.

**Q: How do I reset all settings?**
A: Use the reset button in the app bar of Settings screen.

---

## Future Enhancement Roadmap

### Phase 1: Core Enhancements (Q1 2026)

#### Visual Customization
- [ ] Accent color picker for primary brand color
- [ ] Category customization (reorder, edit name, change icon/color)
- [ ] Enhanced account type theming system

#### Functional Customization
- [ ] Budget settings (default period, method, rollover preferences)
- [ ] Transaction settings (default account, auto-categorization)
- [ ] Multi-currency support with conversion rates

### Phase 2: Accessibility & UX (Q2 2026)

#### Accessibility Features
- [ ] Font size adjustment (small/medium/large/extra large)
- [ ] Bold text toggle for better readability
- [ ] High contrast mode for visual impairments
- [ ] Reduce motion preferences
- [ ] Color blind friendly color schemes

### Phase 3: Advanced Security (Q3 2026)

#### Enhanced Security
- [ ] Change password functionality
- [ ] Trusted devices list and management
- [ ] Auto-lock timeout configuration
- [ ] Advanced activity logging and audit trails

### Phase 4: Automation & Intelligence (Q4 2026)

#### Smart Features
- [ ] AI-powered category suggestions
- [ ] Automatic budget creation based on spending patterns
- [ ] Smart notification scheduling

### Technical Improvements (Ongoing)

#### Performance Optimizations
- [ ] Settings lazy loading for better startup performance
- [ ] Background settings synchronization
- [ ] Memory optimization for large settings objects

---

*This documentation covers all aspects of the Settings feature implementation.*
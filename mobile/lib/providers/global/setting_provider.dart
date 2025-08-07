// =======================>> Flutter Core
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class SettingProvider extends ChangeNotifier {
  // Fields
  bool _isLoading = false;
  String? _error;
  bool _isSelectingLanguage = false;
  bool _hasSeenOnboarding = false; // Added onboarding field
  String? _lang;
  ThemeMode _themeMode = ThemeMode.system;

  // Services
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSelectingLanguage => _isSelectingLanguage;
  bool get hasSeenOnboarding => _hasSeenOnboarding; // Added onboarding getter
  String? get lang => _lang;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Initialize
  SettingProvider() {
    getHome();
  }

  // Functions
  Future<void> getHome() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        handleSelectLanguage(),
        _loadOnboardingStatus(), // Load onboarding status
        _loadThemePreference(),
      ]);
    } catch (e) {
      _error = "Error loading settings: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetOnboardingState() async {
    // Set hasSeenOnboarding to false so AuthMiddleware shows WelcomeScreen
    _hasSeenOnboarding = false;
    notifyListeners();

    // If you're persisting this state, also update the stored value
    // Example: await _prefs.setBool('hasSeenOnboarding', false);
  }

  Future<void> handleSetLanguage(String lang) async {
    try {
      await _storage.write(key: 'lang', value: lang);
      _lang = lang;
      _isSelectingLanguage = true;
      notifyListeners();
    } catch (e) {
      _error = "Failed to set language: $e";
      notifyListeners();
    }
  }

  Future<void> handleSelectLanguage() async {
    try {
      String? langValue = await _storage.read(key: 'lang');
      _lang = langValue ?? '';
      _isSelectingLanguage = _lang!.isNotEmpty;
    } catch (e) {
      await _storage.delete(key: 'lang');
      _lang = '';
      _isSelectingLanguage = false;
      _error = "Failed to read language: $e";
    }
    notifyListeners();
  }

  Future<void> _loadOnboardingStatus() async {
    try {
      String? onboardingStatus = await _storage.read(key: 'onboarding');
      _hasSeenOnboarding = onboardingStatus == 'true';
    } catch (e) {
      _hasSeenOnboarding = false;
      _error = "Failed to load onboarding status: $e";
    }
    notifyListeners();
  }

  Future<void> handleSetOnboardingCompleted() async {
    try {
      await _storage.write(key: 'onboarding', value: 'true');
      _hasSeenOnboarding = true;
      notifyListeners();
    } catch (e) {
      _error = "Failed to set onboarding status: $e";
      notifyListeners();
    }
  }

  Future<void> _loadThemePreference() async {
    try {
      String? theme = await _storage.read(key: 'theme');
      _themeMode = switch (theme) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      };
    } catch (e) {
      _themeMode = ThemeMode.system;
      _error = "Failed to load theme: $e";
    }
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    try {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      await _storage.write(
        key: 'theme',
        value: isDark ? 'dark' : 'light',
      );
      notifyListeners();
    } catch (e) {
      _error = "Failed to toggle theme: $e";
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      String themeValue = switch (mode) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
      };
      await _storage.write(key: 'theme', value: themeValue);
      notifyListeners();
    } catch (e) {
      _error = "Failed to set theme mode: $e";
      notifyListeners();
    }
  }
}

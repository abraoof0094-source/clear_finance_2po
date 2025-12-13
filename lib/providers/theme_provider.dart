import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// THEME PROVIDER - FIXED VERSION
/// ════════════════════════════════════════════════════════════════════════════
///
/// Manages app-wide theme state: light/dark mode + card gradient colors.
/// Persists to SharedPreferences, notifies UI on changes.
class ThemeProvider extends ChangeNotifier {

  // THEME MODE
  ThemeMode _themeMode = ThemeMode.system;

  /// Get current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Is dark mode active?
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Is light mode active?
  bool get isLightMode => _themeMode == ThemeMode.light;

  /// Is system mode active?
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Get current theme name as string (for UI display)
  String get currentThemeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // CARD GRADIENT COLORS
  List<Color> _homeCardColors = [
    const Color(0xFFF59E0B),
    const Color(0xFFEA580C),
  ];

  /// Get home card colors (Amber/Orange default)
  List<Color> get homeCardColors => List.from(_homeCardColors);

  List<Color> _analyticsCardColors = [
    const Color(0xFF3B82F6),
    const Color(0xFF2563EB),
  ];

  /// Get analytics card colors (Blue/Royal default)
  List<Color> get analyticsCardColors => List.from(_analyticsCardColors);

  List<Color> _forecastCardColors = [
    const Color(0xFF7C3AED),
    const Color(0xFF5B21FF),
  ];

  /// Get forecast card colors (Purple/Deep default)
  List<Color> get forecastCardColors => List.from(_forecastCardColors);

  List<Color> _settingsCardColors = [
    const Color(0xFF10B981),
    const Color(0xFF059669),
  ];

  /// Get settings card colors (Green/Emerald default)
  List<Color> get settingsCardColors => List.from(_settingsCardColors);

  ThemeProvider() {
    _loadPreferences();
  }

  /// Load all saved preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    final themeModeIndex = prefs.getInt('theme_mode') ?? 2;
    _themeMode = ThemeMode.values[themeModeIndex];

    // Load card colors
    _homeCardColors = _loadColorPair(prefs, 'home_card_colors', _homeCardColors);
    _analyticsCardColors = _loadColorPair(prefs, 'analytics_card_colors', _analyticsCardColors);
    _forecastCardColors = _loadColorPair(prefs, 'forecast_card_colors', _forecastCardColors);
    _settingsCardColors = _loadColorPair(prefs, 'settings_card_colors', _settingsCardColors);

    notifyListeners();
  }

  /// Helper: Load a color pair from SharedPreferences
  /// Format: "[0xFF1234567,0xFFABCDEF]"
  List<Color> _loadColorPair(
      SharedPreferences prefs,
      String key,
      List<Color> defaultColors,
      ) {
    try {
      final json = prefs.getString(key);
      if (json == null) return defaultColors;

      final values = json
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((v) => int.parse(v.trim()))
          .toList();

      if (values.length >= 2) {
        return [Color(values[0]), Color(values[1])];
      }
    } catch (_) {}
    return defaultColors;
  }

  /// Set theme mode and persist
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_mode', mode.index);
      notifyListeners();
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Set to light mode
  Future<void> setLightMode() => setThemeMode(ThemeMode.light);

  /// Set to dark mode
  Future<void> setDarkMode() => setThemeMode(ThemeMode.dark);

  /// Set to system mode
  Future<void> setSystemMode() => setThemeMode(ThemeMode.system);

  /// Update card color gradient for a specific screen
  Future<void> updateCardColor(String screenKey, List<Color> colors) async {
    if (colors.length != 2) return;

    final prefs = await SharedPreferences.getInstance();
    final colorString = '[${colors[0].value},${colors[1].value}]';

    switch (screenKey) {
      case 'home':
        _homeCardColors = colors;
        await prefs.setString('home_card_colors', colorString);
        break;
      case 'analytics':
        _analyticsCardColors = colors;
        await prefs.setString('analytics_card_colors', colorString);
        break;
      case 'forecast':
        _forecastCardColors = colors;
        await prefs.setString('forecast_card_colors', colorString);
        break;
      case 'settings':
        _settingsCardColors = colors;
        await prefs.setString('settings_card_colors', colorString);
        break;
    }

    notifyListeners();
  }

  /// Reset all card colors to defaults
  Future<void> resetCardColors() async {
    final prefs = await SharedPreferences.getInstance();

    _homeCardColors = [const Color(0xFFF59E0B), const Color(0xFFEA580C)];
    _analyticsCardColors = [const Color(0xFF3B82F6), const Color(0xFF2563EB)];
    _forecastCardColors = [const Color(0xFF7C3AED), const Color(0xFF5B21FF)];
    _settingsCardColors = [const Color(0xFF10B981), const Color(0xFF059669)];

    await prefs.remove('home_card_colors');
    await prefs.remove('analytics_card_colors');
    await prefs.remove('forecast_card_colors');
    await prefs.remove('settings_card_colors');

    notifyListeners();
  }

  /// Get ThemeData for light mode
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2180A0),
        brightness: Brightness.light,
      ),
    );
  }

  /// Get ThemeData for dark mode
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF32B8C6),
        brightness: Brightness.dark,
      ),
    );
  }

  /// Convert internal ThemeMode to Flutter ThemeMode for MaterialApp
  ThemeMode getThemeMode() => _themeMode;

  /// Get card colors for a specific screen
  List<Color> getColorsForKey(String key) {
    switch (key) {
      case 'home':
        return homeCardColors;
      case 'analytics':
        return analyticsCardColors;
      case 'forecast':
        return forecastCardColors;
      case 'settings':
        return settingsCardColors;
      default:
        return homeCardColors;
    }
  }
}

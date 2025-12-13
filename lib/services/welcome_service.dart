import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage first-time welcome screen state
class WelcomeService {
  static const String _keyWelcomeComplete = 'welcome_complete';

  /// Checks if the user has seen the welcome screen
  Future<bool> isWelcomeComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyWelcomeComplete) ?? false;
  }

  /// Marks welcome screen as completed
  Future<void> completeWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyWelcomeComplete, true);
  }

  /// Resets welcome screen state (for testing/debugging)
  Future<void> resetWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyWelcomeComplete, false);
  }
}

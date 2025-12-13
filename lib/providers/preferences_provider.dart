import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider extends ChangeNotifier {
  // Keys for SharedPreferences
  static const String _currencyCodeKey = 'currency_code';
  static const String _currencySymbolKey = 'currency_symbol'; // Added separate key
  static const String _languageKey = 'language_code';
  static const String _notificationKey = 'daily_reminder';
  static const String _appLockKey = 'app_lock_enabled'; // Must match SecurityScreen key
  static const String _reminderHourKey = 'reminder_hour';
  static const String _reminderMinuteKey = 'reminder_minute';
  static const String _customRemindersKey = 'custom_reminders';

  // Default values
  String _currencyCode = 'INR';
  String _currencySymbol = '₹';
  String _languageCode = 'en';
  bool _isDailyReminderEnabled = true;
  bool _isAppLockEnabled = false;
  int _reminderHour = 20; // 8 PM
  int _reminderMinute = 0;

  // Custom reminders list
  List<Map<String, dynamic>> _customReminders = [];

  // Getters
  String get currencyCode => _currencyCode;
  String get currencySymbol => _currencySymbol;
  String get languageCode => _languageCode;
  bool get isDailyReminderEnabled => _isDailyReminderEnabled;
  bool get isAppLockEnabled => _isAppLockEnabled;
  TimeOfDay get reminderTime => TimeOfDay(hour: _reminderHour, minute: _reminderMinute);
  List<Map<String, dynamic>> get customReminders => List.unmodifiable(_customReminders);

  PreferencesProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Currency (Default to INR if missing)
    _currencyCode = prefs.getString(_currencyCodeKey) ?? 'INR';
    _currencySymbol = prefs.getString(_currencySymbolKey) ?? '₹';

    _languageCode = prefs.getString(_languageKey) ?? 'en';
    _isDailyReminderEnabled = prefs.getBool(_notificationKey) ?? true;
    _isAppLockEnabled = prefs.getBool(_appLockKey) ?? false;
    _reminderHour = prefs.getInt(_reminderHourKey) ?? 20;
    _reminderMinute = prefs.getInt(_reminderMinuteKey) ?? 0;

    final rawList = prefs.getStringList(_customRemindersKey) ?? [];
    _customReminders = rawList.map((entry) {
      final parts = entry.split('|');
      final timeParts = parts[0].split(':');
      return {
        'time': TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1])),
        'note': parts.length > 1 ? parts[1] : '',
      };
    }).toList();

    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadPreferences();
  }

  // ───────── CURRENCY LOGIC (Updated) ─────────

  /// Accepts both code and symbol to support ANY currency sent from UI
  Future<void> setCurrency(String code, String symbol) async {
    _currencyCode = code;
    _currencySymbol = symbol;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyCodeKey, code);
    await prefs.setString(_currencySymbolKey, symbol);

    notifyListeners();
  }

  // ───────── LANGUAGE LOGIC ─────────
  Future<void> setLanguage(String code) async {
    if (_languageCode == code) return;
    _languageCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);
    notifyListeners();
  }

  // ───────── NOTIFICATIONS LOGIC ─────────
  Future<void> toggleDailyReminder(bool value) async {
    if (_isDailyReminderEnabled == value) return;
    _isDailyReminderEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationKey, value);
    notifyListeners();
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderHour = time.hour;
    _reminderMinute = time.minute;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderHourKey, _reminderHour);
    await prefs.setInt(_reminderMinuteKey, _reminderMinute);
    notifyListeners();
  }

  // ───────── CUSTOM REMINDERS ─────────
  Future<void> addCustomReminder(TimeOfDay time, String note) async {
    _customReminders.add({'time': time, 'note': note});
    await _saveCustomReminders();
    notifyListeners();
  }

  Future<void> removeCustomReminder(int index) async {
    if (index < 0 || index >= _customReminders.length) return;
    _customReminders.removeAt(index);
    await _saveCustomReminders();
    notifyListeners();
  }

  Future<void> _saveCustomReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _customReminders.map((entry) {
      final TimeOfDay t = entry['time'] as TimeOfDay;
      final String note = (entry['note'] as String?) ?? '';
      return "${t.hour}:${t.minute}|$note";
    }).toList();
    await prefs.setStringList(_customRemindersKey, raw);
  }

  // ───────── SECURITY LOGIC ─────────
  Future<void> toggleAppLock(bool value) async {
    if (_isAppLockEnabled == value) return;
    _isAppLockEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_appLockKey, value);
    notifyListeners();
  }
}

import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  final String tab; // 'theme', 'currency', 'language', 'notifications', 'general'
  const AppSettingsScreen({required this.tab, super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  // Local-only state for now. Later this can move to a Provider + DB.
  ThemeMode _themeMode = ThemeMode.dark;
  String _currency = 'INR (₹)';
  String _language = 'English';
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final String title = widget.tab;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (widget.tab) {
      case 'theme':
        return _buildThemeSettings();
      case 'currency':
        return _buildCurrencySettings();
      case 'language':
        return _buildLanguageSettings();
      case 'notifications':
        return _buildNotificationSettings();
      case 'general':
      default:
        return _buildGeneralSettings();
    }
  }

  // THEME

  Widget _buildThemeSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'choose how clear finance looks',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        _radioTile<ThemeMode>(
          title: 'dark',
          subtitle: 'recommended for battery and eyes',
          value: ThemeMode.dark,
          groupValue: _themeMode,
          onChanged: (v) {
            if (v == null) return;
            setState(() => _themeMode = v);
            // TODO: push to global app theme via Provider later
          },
        ),
        _radioTile<ThemeMode>(
          title: 'light',
          subtitle: 'classic bright mode',
          value: ThemeMode.light,
          groupValue: _themeMode,
          onChanged: (v) {
            if (v == null) return;
            setState(() => _themeMode = v);
          },
        ),
        _radioTile<ThemeMode>(
          title: 'system',
          subtitle: 'follow your phone\'s theme',
          value: ThemeMode.system,
          groupValue: _themeMode,
          onChanged: (v) {
            if (v == null) return;
            setState(() => _themeMode = v);
          },
        ),
      ],
    );
  }

  // CURRENCY

  Widget _buildCurrencySettings() {
    final currencies = <String>[
      'INR (₹)',
      'USD (\$)',
      'EUR (€)',
      'GBP (£)',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'default currency for your numbers',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        ...currencies.map(
              (c) => _radioTile<String>(
            title: c.toLowerCase(),
            subtitle: null,
            value: c,
            groupValue: _currency,
            onChanged: (v) {
              if (v == null) return;
              setState(() => _currency = v);
              // TODO: wire to FinanceProvider.currencyFormat later
            },
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'note: this changes how values are displayed. existing data is not converted yet.',
          style: TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ],
    );
  }

  // LANGUAGE

  Widget _buildLanguageSettings() {
    final languages = <String>[
      'English',
      'Hindi',
      'Tamil',
      'Malayalam',
      'Telugu',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'choose your preferred language',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        ...languages.map(
              (lang) => _radioTile<String>(
            title: lang.toLowerCase(),
            subtitle: lang == 'English'
                ? 'current'
                : 'ui translation coming soon',
            value: lang,
            groupValue: _language,
            onChanged: (v) {
              if (v == null) return;
              setState(() => _language = v);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'language selection saved. translations will be added in a later update.',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // NOTIFICATIONS

  Widget _buildNotificationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'control alerts from clear finance',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          value: _notificationsEnabled,
          activeColor: const Color(0xFF3B82F6),
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
            // TODO: hook into real notification system later
          },
          title: const Text(
            'notifications',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: const Text(
            'spend alerts and monthly summaries',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'you can control system-level notification permissions from your phone settings.',
          style: TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ],
    );
  }

  // GENERAL

  Widget _buildGeneralSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'general app options will appear here.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        SizedBox(height: 8),
        Text(
          'examples: auto-backup frequency, default start screen, experimental features.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _radioTile<T>({
    required String title,
    String? subtitle,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RadioListTile<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: const Color(0xFF3B82F6),
        tileColor: Colors.transparent,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ),
    );
  }
}

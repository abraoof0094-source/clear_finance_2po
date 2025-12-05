import 'package:flutter/material.dart';
// We only need this one external import because MoneyScreen IS in a separate file
import 'money_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    // PROFILE Section
                    _buildSectionTitle('profile'),
                    _buildMenuItem(
                      context,
                      icon: Icons.person_outline,
                      label: 'edit profile',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                      },
                    ),

                    const SizedBox(height: 8),

                    // --- MONEY Section (UPDATED) ---
                    _buildSectionTitle('money'),
                    _buildMenuItem(
                      context,
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'financial structure',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MoneyScreen(initialIndex: 0)));
                      },
                    ),
                    // -------------------------------

                    const SizedBox(height: 8),

                    // APP Section
                    _buildSectionTitle('app'),
                    _buildMenuItem(
                      context,
                      icon: Icons.brightness_4_outlined,
                      label: 'theme',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AppSettingsScreen(tab: 'theme')));
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.currency_rupee,
                      label: 'currency',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AppSettingsScreen(tab: 'currency')));
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.language,
                      label: 'language',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AppSettingsScreen(tab: 'language')));
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.notifications_outlined,
                      label: 'notifications',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AppSettingsScreen(tab: 'notifications')));
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings_outlined,
                      label: 'general',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AppSettingsScreen(tab: 'general')));
                      },
                    ),

                    const SizedBox(height: 8),

                    // STORAGE Section
                    _buildSectionTitle('storage'),
                    _buildMenuItem(
                      context,
                      icon: Icons.cloud_upload_outlined,
                      label: 'cloud sync',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Text(
                          'coming soon',
                          style: TextStyle(fontSize: 10, color: Colors.white54),
                        ),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cloud sync coming in next update'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.storage_outlined,
                      label: 'local storage',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const StorageScreen()));
                      },
                    ),

                    const SizedBox(height: 8),

                    // MORE Section
                    _buildSectionTitle('more'),
                    _buildMenuItem(
                      context,
                      icon: Icons.description_outlined,
                      label: 'privacy',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MoreScreen(tab: 'privacy')));
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.help_outline,
                      label: 'help',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MoreScreen(tab: 'help')));
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.email_outlined,
                      label: 'contact us',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MoreScreen(tab: 'contact')));
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.info_outline,
                      label: 'about',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MoreScreen(tab: 'about')));
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
        Widget? trailing,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF3B82F6), size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ??
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white24,
                  size: 12,
                ),
          ],
        ),
      ),
    );
  }
}


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      // TODO: connect to UserProfile model + DB later
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved (stub only for now).')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'edit profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'basic details',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildFieldLabel('name'),
              _buildTextField(
                controller: _nameController,
                hint: 'your name',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'enter a name or nickname';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildFieldLabel('email (optional)'),
              _buildTextField(
                controller: _emailController,
                hint: 'for backups or support',
                keyboardType: TextInputType.emailAddress,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        validator: validator,
      ),
    );
  }
}

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

  // Helper for radio tiles

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

// --- 5. STORAGE SCREEN (Export, Import, Clear) ---

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  bool _isClearing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'local storage',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'backup and manage your clear finance data on this device.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // EXPORT
            _storageTile(
              icon: Icons.file_upload_outlined,
              title: 'export backup',
              subtitle: '.bak file with your transactions and settings',
              color: const Color(0xFF3B82F6),
              onTap: _exportBackup,
            ),
            const SizedBox(height: 10),

            // IMPORT
            _storageTile(
              icon: Icons.file_download_outlined,
              title: 'import backup',
              subtitle: 'restore from a .bak file',
              color: const Color(0xFF10B981),
              onTap: _importBackup,
            ),
            const SizedBox(height: 24),

            const Divider(color: Colors.white12),
            const SizedBox(height: 16),

            const Text(
              'danger zone',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // CLEAR ALL DATA
            _storageTile(
              icon: Icons.delete_forever_outlined,
              title: 'clear all data',
              subtitle: 'delete every transaction and setting from this device',
              color: Colors.redAccent,
              onTap: _confirmClearAll,
            ),
          ],
        ),
      ),
    );
  }

  Widget _storageTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // --- ACTIONS ---

  Future<void> _exportBackup() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('exporting .bak backup (stub for now)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _importBackup() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('import from .bak (stub for now)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmClearAll() async {
    showDialog(
      context: context,
      barrierDismissible: !_isClearing,
      builder: (context) => _ClearAllDialog(
        isProcessing: _isClearing,
        onConfirm: _clearAllData,
      ),
    );
  }

  Future<void> _clearAllData() async {
    setState(() => _isClearing = true);

    // TODO: actually clear DB tables and local prefs
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isClearing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('all local data cleared'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}

// Hard confirmation dialog with checkbox

class _ClearAllDialog extends StatefulWidget {
  final bool isProcessing;
  final Future<void> Function() onConfirm;

  const _ClearAllDialog({
    required this.isProcessing,
    required this.onConfirm,
  });

  @override
  State<_ClearAllDialog> createState() => _ClearAllDialogState();
}

class _ClearAllDialogState extends State<_ClearAllDialog> {
  bool _ack = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
          SizedBox(width: 8),
          Text('Delete Everything?', style: TextStyle(color: Colors.white)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This will permanently delete ALL your data:\n• All transactions\n• Salary & investment settings\n• App preferences\n\nThis action CANNOT be undone.',
            style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => setState(() => _ack = !_ack),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _ack,
                    activeColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.grey),
                    onChanged: (v) => setState(() => _ack = v ?? false),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'I understand, delete everything',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.isProcessing ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: (_ack && !widget.isProcessing)
              ? () {
            Navigator.pop(context); // Close dialog
            widget.onConfirm(); // Run logic
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            disabledBackgroundColor: Colors.redAccent.withOpacity(0.3),
          ),
          child: widget.isProcessing
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Text('Delete Data', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}


// --- 6. MORE SCREEN (Privacy, Help, Contact, About) ---

class MoreScreen extends StatelessWidget {
  final String tab; // 'privacy', 'help', 'contact', 'about'
  const MoreScreen({required this.tab, super.key});

  @override
  Widget build(BuildContext context) {
    String title = tab;
    Widget content = const SizedBox();

    switch (tab) {
      case 'privacy':
        title = 'privacy policy';
        content = _buildPrivacyContent();
        break;
      case 'help':
        title = 'help & faq';
        content = _buildHelpContent();
        break;
      case 'contact':
        title = 'contact us';
        content = _buildContactContent(context);
        break;
      case 'about':
        title = 'about clear finance';
        content = _buildAboutContent();
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: content,
      ),
    );
  }

  Widget _buildPrivacyContent() {
    return const Text(
      'Clear Finance respects your privacy.\n\n'
          '1. Data Storage: All your financial data is stored locally on your device. We do not have access to your transactions.\n\n'
          '2. Analytics: We do not track your personal spending habits.\n\n'
          '3. Internet: The app only uses internet for backup features (if enabled) and checking for updates.\n\n'
          'For full details, visit clearfinance.app/privacy',
      style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
    );
  }

  Widget _buildHelpContent() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Q: How is "Safe to Spend" calculated?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'A: It takes your monthly salary, subtracts your investment goal and fixed bills, then subtracts what you have spent so far this month.',
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 20),
        Text(
          'Q: Can I export my data?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'A: Yes, go to Settings > Storage > Local Storage > Export.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildContactContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.email_outlined, size: 48, color: Color(0xFF3B82F6)),
          const SizedBox(height: 16),
          const Text(
            'Need help?',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'support@clearfinance.app',
            style: TextStyle(color: Colors.blueAccent, fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opens email app...')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
            child: const Text('Send Email', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutContent() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1877F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          const Text(
            'clear finance',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'v1.0.0',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),
          const Text(
            'Designed to help you build wealth\nby making finances clear.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 80),
          const Text(
            '© 2025 Clear Finance',
            style: TextStyle(color: Colors.white12, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

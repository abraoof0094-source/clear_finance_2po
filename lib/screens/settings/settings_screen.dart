import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_profile.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../services/auth_service.dart';

import '../settings/categories_screen.dart';
import '../settings/edit_profile_screen.dart';
import '../settings/preferences_screen.dart';
import '../settings/backup_screen.dart';
import '../settings/support_screen.dart';
import '../settings/appearance_screen.dart';
import '../settings/recurring_transactions_screen.dart'; // <--- ADD IMPORT
import '../security/security_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _navToSecurity() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SecurityScreen()),
    );
    if (mounted) {
      context.read<PreferencesProvider>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Fetch Profile
    final profile = context.watch<UserProfileProvider>().profile;

    // 2. Fetch Theme & Dynamic Colors
    final themeProvider = context.watch<ThemeProvider>();
    final String currentThemeName = themeProvider.currentThemeName;
    final List<Color> settingsGradient = themeProvider.settingsCardColors;

    // 3. Fetch Category Count
    final financeProvider = context.watch<FinanceProvider>();
    final int categoryCount = financeProvider.categories.length;

    // 4. Fetch Preferences
    final prefsProvider = context.watch<PreferencesProvider>();
    final bool isAppLockEnabled = prefsProvider.isAppLockEnabled;

    final String currencyCode = prefsProvider.currencyCode;
    final String currencySymbol = prefsProvider.currencySymbol;
    final String currencySubtitle = "$currencyCode ($currencySymbol)";

    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111827) : Colors.white;
    final subTextColor = onBg.withOpacity(0.6);
    final borderColor = theme.dividerColor.withOpacity(0.1);

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'clear finance',
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── HERO CARD ───
                  _buildSettingsCard(
                    profile,
                    isAppLockEnabled,
                    currentThemeName,
                    categoryCount,
                    settingsGradient,
                  ),

                  const SizedBox(height: 28),

                  _buildSectionHeader("Account & Preferences", subTextColor),
                  _buildSettingsGroup(cardColor, borderColor, isDark, [
                    // 🔁 RECURRING TRANSACTIONS TILE ADDED HERE
                    _buildTile(
                      icon: Icons.autorenew_rounded,
                      title: "Subscriptions & Recurring",
                      subtitle: "Manage auto-logged expenses",
                      color: Colors.blueAccent,
                      onBg: onBg,
                      subTextColor: subTextColor,
                      onTap: () => _navTo(const RecurringTransactionsScreen()),
                    ),
                    _buildTile(
                      icon: Icons.palette_rounded,
                      title: "Appearance",
                      subtitle: currentThemeName,
                      color: Colors.purpleAccent,
                      onBg: onBg,
                      subTextColor: subTextColor,
                      onTap: () => _navTo(const AppearanceScreen()),
                    ),
                    _buildTile(
                      icon: Icons.currency_rupee_rounded,
                      title: "Currency",
                      subtitle: currencySubtitle,
                      color: Colors.greenAccent,
                      onBg: onBg,
                      subTextColor: subTextColor,
                      onTap: () =>
                          _navTo(const PreferencesScreen(tab: 'currency')),
                    ),
                    _buildTile(
                      icon: Icons.fingerprint_rounded,
                      title: "App Lock",
                      subtitle: isAppLockEnabled ? "Enabled" : "Disabled",
                      color: Colors.cyanAccent,
                      onBg: onBg,
                      subTextColor: subTextColor,
                      onTap: _navToSecurity,
                    ),
                    _buildTile(
                      icon: Icons.category_rounded,
                      title: "Categories",
                      subtitle: "$categoryCount active",
                      color: Colors.orangeAccent,
                      onBg: onBg,
                      subTextColor: subTextColor,
                      onTap: () =>
                          _navTo(const CategoriesScreen(initialIndex: 0)),
                    ),
                    _buildTile(
                      icon: Icons.notifications_active_rounded,
                      title: "Notifications",
                      color: Colors.pinkAccent,
                      onBg: onBg,
                      subTextColor: subTextColor,
                      onTap: () =>
                          _navTo(const PreferencesScreen(tab: 'notifications')),
                    ),
                    _buildTile(
                      icon: Icons.language_rounded,
                      title: "Language",
                      subtitle: "English",
                      color: Colors.tealAccent,
                      onBg: onBg,
                      subTextColor: subTextColor,
                      onTap: () =>
                          _navTo(const PreferencesScreen(tab: 'language')),
                    ),
                  ]),

                  const SizedBox(height: 24),
                  // ... (Rest of the file remains identical)
                  _buildSectionHeader("Data Management", subTextColor),
                  _buildSettingsGroup(cardColor, borderColor, isDark, [
                    _buildTile(
                      icon: Icons.cloud_sync_rounded,
                      title: "Backups & Sync",
                      subtitle: "Cloud, CSV, and Restore",
                      color: Colors.blueAccent,
                      onBg: onBg,
                      subTextColor: subTextColor,
                      onTap: () => _navTo(const BackupScreen()),
                    ),
                    _buildTile(
                      icon: Icons.delete_forever_rounded,
                      title: "Reset App Data",
                      subtitle: "Clear all data & start fresh",
                      color: Colors.redAccent,
                      onBg: onBg,
                      subTextColor: subTextColor,
                      isDestructive: true,
                      onTap: () => _showResetDialog(context),
                    ),
                  ]),

                  const SizedBox(height: 24),
                  _buildSectionHeader("Help & Info", subTextColor),
                  _buildSettingsGroup(cardColor, borderColor, isDark, [
                    _buildTile(
                      icon: Icons.help_outline_rounded,
                      title: "Help & Support",
                      color: Colors.blueGrey,
                      onBg: onBg,
                      subTextColor: subTextColor,
                      onTap: () => _navTo(const SupportScreen(tab: 'help')),
                    ),
                    _buildTile(
                      icon: Icons.privacy_tip_outlined,
                      title: "Privacy Policy",
                      color: Colors.blueGrey,
                      onBg: onBg,
                      subTextColor: subTextColor,
                      onTap: () => _navTo(const SupportScreen(tab: 'privacy')),
                    ),
                    _buildTile(
                      icon: Icons.info_outline_rounded,
                      title: "About",
                      color: Colors.blueGrey,
                      onBg: onBg,
                      subTextColor: subTextColor,
                      onTap: () => _navTo(const SupportScreen(tab: 'about')),
                    ),
                  ]),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      "v1.0.0 • Clear Finance",
                      style: TextStyle(
                        color: subTextColor.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (Keep existing helpers: _buildSettingsCard, _buildMiniStatusRow, _navTo, etc.)
  Widget _buildSettingsCard(
      UserProfile profile,
      bool isAppLockOn,
      String themeName,
      int catCount,
      List<Color> gradientColors,
      ) {
    // (Your existing code here)
    const textColor = Colors.black;
    final subTextColor = Colors.black.withOpacity(0.7);
    final boxColor = Colors.white.withOpacity(0.2);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: boxColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.black.withOpacity(0.1), width: 1),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.black, // Black Icon
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      profile.name.isEmpty ? "No Name" : profile.name,
                      style: const TextStyle(
                        color: textColor, // Black
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (profile.email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        profile.email,
                        style: TextStyle(
                          color: subTextColor, // Dark Gray
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _navTo(EditProfileScreen(
                  initialName: profile.name,
                  initialEmail: profile.email,
                  initialPhone: profile.phone,
                )),
                icon: const Icon(Icons.edit_rounded),
                color: Colors.black, // Black Icon
                splashRadius: 20,
                tooltip: 'Edit profile',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              // BOX 1: STORAGE
              Expanded(
                child: StreamBuilder<User?>(
                  stream: AuthService().authStateChanges,
                  builder: (context, snapshot) {
                    final isCloud = snapshot.hasData && snapshot.data != null;
                    final statusText = isCloud ? "Cloud Sync" : "Local only";
                    final statusIcon = isCloud
                        ? Icons.cloud_done_rounded
                        : Icons.smartphone_rounded;

                    return GestureDetector(
                      onTap: () => _navTo(const BackupScreen()),
                      child: Container(
                        height: 88,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: boxColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.05),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.storage_rounded,
                                  size: 16,
                                  color: subTextColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Data storage",
                                  style: TextStyle(
                                    color: subTextColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Icon(statusIcon, size: 18, color: textColor),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    statusText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: textColor, // Black
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // BOX 2: APP STATS
              Expanded(
                child: Container(
                  height: 88,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStatusRow(
                        isAppLockOn
                            ? Icons.lock_outline_rounded
                            : Icons.lock_open_rounded,
                        isAppLockOn ? "App Secured" : "Unlocked",
                        textColor,
                      ),
                      _buildMiniStatusRow(
                        Icons.palette_outlined,
                        "$themeName Theme",
                        textColor,
                      ),
                      _buildMiniStatusRow(
                        Icons.category_outlined,
                        "$catCount Categories",
                        textColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatusRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: color.withOpacity(0.85),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color.withOpacity(0.95),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _navTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _showResetDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(
          "Reset App Data?",
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          "This will permanently delete all your transactions...",
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("App reset successful")),
              );
            },
            child: const Text(
              "Reset",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(
      Color cardColor,
      Color borderColor,
      bool isDark,
      List<Widget> children,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(
                color: borderColor,
                height: 1,
                indent: 60,
                endIndent: 20,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    required Color onBg,
    required Color subTextColor,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.redAccent : onBg,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          subtitle,
          style: TextStyle(
            color: subTextColor,
            fontSize: 12,
          ),
        ),
      )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: onBg.withOpacity(0.2),
        size: 20,
      ),
    );
  }
}

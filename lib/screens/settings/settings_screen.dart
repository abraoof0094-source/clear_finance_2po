import 'package:flutter/material.dart';
import 'categories_screen.dart';
import 'profile_settings_screen.dart';
import 'app_settings_screen.dart';
import 'data_hub_screen.dart'; // Make sure this file exists
import 'more_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: wire real user data
    const userName = 'Raoof';
    const userEmail = 'ab.raoof0094@gmail.com';

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Use SliverPadding to wrap the content
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    // --- HEADER ---
                    Column(
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
                        const SizedBox(height: 20),

                        // --- PROFILE HERO CARD ---
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('SETTINGS', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
                                    const SizedBox(height: 4),
                                    const Text(userName, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                    const Text(userEmail, style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),

                    // --- SECTION 1: DATA & FINANCE ---
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12, left: 4),
                      child: Text("General", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                    _buildSettingsGroup([
                      _buildTile(
                        icon: Icons.account_balance_wallet_rounded,
                        title: "Categories",
                        subtitle: "Manage income & expense types",
                        color: Colors.orangeAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen(initialIndex: 0))),
                      ),
                      _buildTile(
                        icon: Icons.cloud_sync_rounded, // Modern icon for Data Hub
                        title: "Data & Sync",           // New name
                        subtitle: "Backup, Restore, Cloud Settings",
                        color: Colors.blueAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataHubScreen())), // Connects to new screen
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // --- SECTION 2: PREFERENCES ---
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12, left: 4),
                      child: Text("Preferences", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                    _buildSettingsGroup([
                      _buildTile(
                        icon: Icons.palette_rounded,
                        title: "Theme",
                        color: Colors.purpleAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppSettingsScreen(tab: 'theme'))),
                      ),
                      _buildTile(
                        icon: Icons.currency_rupee_rounded,
                        title: "Currency",
                        color: Colors.greenAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppSettingsScreen(tab: 'currency'))),
                      ),
                      _buildTile(
                        icon: Icons.notifications_active_rounded,
                        title: "Notifications",
                        color: Colors.redAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppSettingsScreen(tab: 'notifications'))),
                      ),
                      _buildTile(
                        icon: Icons.language_rounded,
                        title: "Language",
                        color: Colors.tealAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppSettingsScreen(tab: 'language'))),
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // --- SECTION 3: SUPPORT ---
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12, left: 4),
                      child: Text("Support", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                    _buildSettingsGroup([
                      _buildTile(
                        icon: Icons.privacy_tip_rounded,
                        title: "Privacy Policy",
                        color: Colors.grey,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoreScreen(tab: 'privacy'))),
                      ),
                      _buildTile(
                        icon: Icons.help_outline_rounded,
                        title: "Help & Support",
                        color: Colors.grey,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoreScreen(tab: 'help'))),
                      ),
                      _buildTile(
                        icon: Icons.info_outline_rounded,
                        title: "About",
                        color: Colors.grey,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoreScreen(tab: 'about'))),
                      ),
                    ]),

                    const SizedBox(height: 40),

                    // Version Tag
                    const Center(
                      child: Text(
                        "v1.0.0 • Made with ❤️",
                        style: TextStyle(color: Colors.white24, fontSize: 12),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) // Add divider except for last item
              Divider(color: Colors.white.withOpacity(0.05), height: 1, indent: 56),
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
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)) : null,
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.3), size: 20),
    );
  }
}

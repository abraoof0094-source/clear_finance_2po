import 'package:flutter/material.dart';
import 'categories_screen.dart';
import 'profile_settings_screen.dart';
import 'app_settings_screen.dart';
import 'storage_screen.dart';
import 'more_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Control expansion states
  bool _categoriesOpen = false;
  bool _appOpen = false;
  bool _storageOpen = false;
  bool _moreOpen = false;

  @override
  Widget build(BuildContext context) {
    // TODO: wire real user data
    const userName = 'Raoof';
    const userEmail = 'ab.raoof0094@gmail.com';

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A), // Match Home BG
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // Match Home Padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24), // Match Home top spacing

              // --- HEADER (Matches Home) ---
              const Text(
                'clear finance',
                style: TextStyle(
                  color: Color(0xFF3B82F6), // Match Home Blue
                  fontSize: 26, // Match Home Size
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 20), // Spacing after header

              // --- HERO CARD (Indigo/Purple) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24), // Match Home card padding
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1), // Indigo
                  borderRadius: BorderRadius.circular(28), // Match Home radius
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
                    // Profile Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SETTINGS',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            userName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            userEmail,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Edit Button
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- EXPANDABLE SETTINGS LIST ---
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    // 1. Categories
                    _buildExpandableCard(
                      title: 'Categories',
                      icon: Icons.account_balance_wallet_outlined,
                      isOpen: _categoriesOpen,
                      onToggle: () {
                        setState(() => _categoriesOpen = !_categoriesOpen);
                      },
                      children: [
                        _buildSubItem(
                          context,
                          label: 'Manage categories',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const CategoriesScreen(initialIndex: 0),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // 2. App settings
                    _buildExpandableCard(
                      title: 'App settings',
                      icon: Icons.settings_suggest_outlined,
                      isOpen: _appOpen,
                      onToggle: () {
                        setState(() => _appOpen = !_appOpen);
                      },
                      children: [
                        _buildSubItem(
                          context,
                          label: 'Theme',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const AppSettingsScreen(tab: 'theme'),
                              ),
                            );
                          },
                        ),
                        _buildSubItem(
                          context,
                          label: 'Currency',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const AppSettingsScreen(tab: 'currency'),
                              ),
                            );
                          },
                        ),
                        _buildSubItem(
                          context,
                          label: 'Language',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const AppSettingsScreen(tab: 'language'),
                              ),
                            );
                          },
                        ),
                        _buildSubItem(
                          context,
                          label: 'Notifications',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const AppSettingsScreen(
                                    tab: 'notifications'),
                              ),
                            );
                          },
                        ),
                        _buildSubItem(
                          context,
                          label: 'General',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const AppSettingsScreen(tab: 'general'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // 3. Storage settings
                    _buildExpandableCard(
                      title: 'Storage settings',
                      icon: Icons.storage_outlined,
                      isOpen: _storageOpen,
                      onToggle: () {
                        setState(() => _storageOpen = !_storageOpen);
                      },
                      children: [
                        _buildSubItem(
                          context,
                          label: 'Cloud sync',
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: const Text(
                              'Coming soon',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Cloud sync coming in a future update'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        _buildSubItem(
                          context,
                          label: 'Local storage',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const StorageScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // 4. More info
                    _buildExpandableCard(
                      title: 'More info',
                      icon: Icons.info_outline,
                      isOpen: _moreOpen,
                      onToggle: () {
                        setState(() => _moreOpen = !_moreOpen);
                      },
                      children: [
                        _buildSubItem(
                          context,
                          label: 'Privacy',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const MoreScreen(tab: 'privacy'),
                              ),
                            );
                          },
                        ),
                        _buildSubItem(
                          context,
                          label: 'Help',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const MoreScreen(tab: 'help'),
                              ),
                            );
                          },
                        ),
                        _buildSubItem(
                          context,
                          label: 'Contact us',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const MoreScreen(tab: 'contact'),
                              ),
                            );
                          },
                        ),
                        _buildSubItem(
                          context,
                          label: 'About',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const MoreScreen(tab: 'about'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS FOR EXPANDABLE CARDS ---

  Widget _buildExpandableCard({
    required String title,
    required IconData icon,
    required bool isOpen,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Match Home Transaction Item BG
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white70, size: 20),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white38,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Column(children: children),
            ),
        ],
      ),
    );
  }

  Widget _buildSubItem(
      BuildContext context, {
        required String label,
        required VoidCallback onTap,
        Widget? trailing,
      }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const SizedBox(width: 34),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
            trailing ??
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white24,
                  size: 14,
                ),
          ],
        ),
      ),
    );
  }
}

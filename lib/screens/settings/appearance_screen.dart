import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

// Simple model to hold gradient presets
class GradientPreset {
  final String name;
  final List<Color> colors;
  const GradientPreset(this.name, this.colors);
}

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  // ─── 10 GRADIENT PAIRS (Starting with your requested Orange Shade) ───
  static const List<GradientPreset> gradients = [
    GradientPreset("Amber/Orange", [Color(0xFFF59E0B), Color(0xFFEA580C)]),
    GradientPreset("Purple/Deep", [Color(0xFF7C3AED), Color(0xFF5B21FF)]),
    GradientPreset("Blue/Royal", [Color(0xFF3B82F6), Color(0xFF2563EB)]),
    GradientPreset("Red/Crimson", [Color(0xFFEF4444), Color(0xFFDC2626)]),
    GradientPreset("Green/Emerald", [Color(0xFF10B981), Color(0xFF059669)]),
    GradientPreset("Pink/Rose", [Color(0xFFEC4899), Color(0xFFDB2777)]),
    GradientPreset("Teal/Cyan", [Color(0xFF14B8A6), Color(0xFF0D9488)]),
    GradientPreset("Cyan/Sky", [Color(0xFF06B6D4), Color(0xFF0891B2)]),
    GradientPreset("Indigo/Violet", [Color(0xFF6366F1), Color(0xFF4F46E5)]),
    GradientPreset("Midnight/Slate", [Color(0xFF1E293B), Color(0xFF0F172A)]),
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Connect to Provider
    final themeProvider = context.watch<ThemeProvider>();

    // 2. Dynamic Colors
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = theme.scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF111827) : Colors.white;
    final textColor = theme.colorScheme.onSurface;
    final subTextColor = textColor.withOpacity(0.6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Appearance",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ─── SECTION 1: APP THEME MODE ───
            _buildSectionHeader("App Theme Mode", subTextColor),
            const SizedBox(height: 12),
            _buildThemeOption(
              mode: ThemeMode.system,
              title: "System Default",
              icon: Icons.brightness_auto_rounded,
              cardColor: cardColor,
              textColor: textColor,
              isDark: isDark,
              themeProvider: themeProvider,
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              mode: ThemeMode.light,
              title: "Light Mode",
              icon: Icons.light_mode_rounded,
              cardColor: cardColor,
              textColor: textColor,
              isDark: isDark,
              themeProvider: themeProvider,
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              mode: ThemeMode.dark,
              title: "Dark Mode",
              icon: Icons.dark_mode_rounded,
              cardColor: cardColor,
              textColor: textColor,
              isDark: isDark,
              themeProvider: themeProvider,
            ),

            const SizedBox(height: 32),

            // ─── SECTION 2: CUSTOMIZE CARD COLORS ───
            _buildSectionHeader("Customize Card Colors", subTextColor),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDark ? [] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildColorPickerTile(
                    context,
                    title: "Analytics Card",
                    screenKey: 'analytics',
                    currentColors: themeProvider.analyticsCardColors,
                    isDark: isDark,
                    textColor: textColor,
                    themeProvider: themeProvider,
                  ),
                  Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
                  _buildColorPickerTile(
                    context,
                    title: "Home Dashboard",
                    screenKey: 'home',
                    currentColors: themeProvider.homeCardColors,
                    isDark: isDark,
                    textColor: textColor,
                    themeProvider: themeProvider,
                  ),
                  Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
                  _buildColorPickerTile(
                    context,
                    title: "Forecast Card",
                    screenKey: 'forecast',
                    currentColors: themeProvider.forecastCardColors,
                    isDark: isDark,
                    textColor: textColor,
                    themeProvider: themeProvider,
                  ),
                  Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
                  _buildColorPickerTile(
                    context,
                    title: "Settings Card",
                    screenKey: 'settings',
                    currentColors: themeProvider.settingsCardColors,
                    isDark: isDark,
                    textColor: textColor,
                    themeProvider: themeProvider,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ─── RESET BUTTON ───
            Center(
              child: TextButton.icon(
                onPressed: () {
                  themeProvider.resetCardColors();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Colors reset to default")),
                  );
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Reset Colors to Default"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─── WIDGET BUILDERS ───

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
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

  Widget _buildThemeOption({
    required ThemeMode mode,
    required String title,
    required IconData icon,
    required Color cardColor,
    required Color textColor,
    required bool isDark,
    required ThemeProvider themeProvider,
  }) {
    final isSelected = themeProvider.themeMode == mode;
    final activeColor = const Color(0xFF6366F1);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.05);

    return GestureDetector(
      onTap: () => themeProvider.setThemeMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withOpacity(0.2)
                    : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? activeColor : textColor.withOpacity(0.5),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: activeColor, size: 24),
          ],
        ),
      ),
    );
  }

  // ─── UPDATED: Compact Color Indicator ───
  Widget _buildColorPickerTile(
      BuildContext context, {
        required String title,
        required String screenKey,
        required List<Color> currentColors,
        required bool isDark,
        required Color textColor,
        required ThemeProvider themeProvider,
      }) {
    // Determine the representative color (primary color of the gradient)
    final primaryColor = currentColors.isNotEmpty ? currentColors.first : Colors.grey;

    return ListTile(
      onTap: () => _showColorPickerSheet(context, screenKey, themeProvider),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4), // Reduced vertical padding
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Container(
        width: 24, // Smaller size for "radio button" look
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryColor, // Solid color representative
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.black12,
            width: 2, // Slight border for contrast
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPickerSheet(
      BuildContext context, String screenKey, ThemeProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Color for ${screenKey.toUpperCase()}",
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // Increased column count for compactness
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: gradients.length,
                itemBuilder: (context, index) {
                  final preset = gradients[index];
                  // Check if this preset is currently selected
                  final isSelected = _isColorListEqual(provider.getColorsForKey(screenKey), preset.colors);

                  return GestureDetector(
                    onTap: () {
                      provider.updateCardColor(screenKey, preset.colors);
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: preset.colors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: isDark ? Colors.white12 : Colors.black12,
                                  ),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: preset.colors.first.withOpacity(0.6),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    )
                                  ] : [],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          preset.name.split('/')[0],
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  bool _isColorListEqual(List<Color> list1, List<Color> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].value != list2[i].value) return false;
    }
    return true;
  }
}

// Extension to help helper function work seamlessly
extension ThemeProviderHelper on ThemeProvider {
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

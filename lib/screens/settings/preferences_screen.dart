import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/preferences_provider.dart';
import 'currency_screen.dart';

class PreferencesScreen extends StatelessWidget {
  final String tab;
  const PreferencesScreen({required this.tab, super.key});

  @override
  Widget build(BuildContext context) {
    // 1. If the tab is 'currency', immediately delegate to your dedicated screen
    if (tab == 'currency') {
      return const CurrencyScreen();
    }

    // 2. Otherwise, handle Notifications or Language normally
    final provider = context.watch<PreferencesProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;

    String title = "Preferences";
    Widget content = const SizedBox();

    switch (tab) {
      case 'notifications':
        title = "Notifications";
        content = _buildNotifications(context, theme, isDark, provider);
        break;
      case 'language':
        title = "Language";
        content = _buildLanguageList(theme, isDark, provider);
        break;
      default:
        content = Center(child: Text("Unknown tab: $tab"));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: content,
    );
  }

  // ───────── NOTIFICATIONS TAB ─────────
  Widget _buildNotifications(
      BuildContext context,
      ThemeData theme,
      bool isDark,
      PreferencesProvider provider,
      ) {
    final cardColor = isDark ? const Color(0xFF111827) : Colors.white;
    final textColor = theme.colorScheme.onSurface;
    final subTextColor = textColor.withOpacity(0.6);
    final borderColor = theme.dividerColor.withOpacity(0.1);
    const brandColor = Color(0xFF3B82F6);

    final TimeOfDay reminderTime = provider.reminderTime;
    final String formattedTime = reminderTime.format(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily Check-in
          Container(
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
                SwitchListTile(
                  value: provider.isDailyReminderEnabled,
                  activeColor: brandColor,
                  title: const Text(
                    "Daily Check-in",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    "Reminder to log expenses",
                    style: TextStyle(color: subTextColor, fontSize: 13),
                  ),
                  secondary: const Icon(
                    Icons.notifications_active_rounded,
                    color: brandColor,
                  ),
                  onChanged: (val) => provider.toggleDailyReminder(val),
                ),
                Divider(
                    height: 1, color: borderColor, indent: 60, endIndent: 20),
                ListTile(
                  title: const Text(
                    "Check-in Time",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    formattedTime,
                    style: TextStyle(color: subTextColor),
                  ),
                  trailing: const Icon(
                    Icons.access_time_rounded,
                    color: brandColor,
                  ),
                  onTap: () => _pickReminderTime(context, provider),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Custom Reminders
          Text(
            "CUSTOM REMINDERS",
            style: TextStyle(
              color: subTextColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),

          if (provider.customReminders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "No custom reminders yet.",
                style: TextStyle(color: subTextColor, fontSize: 13),
              ),
            )
          else
            ...List.generate(provider.customReminders.length, (index) {
              final data = provider.customReminders[index];
              final TimeOfDay time = data['time'] as TimeOfDay;
              final String note = (data['note'] as String?) ?? '';
              final String timeText = time.format(context);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: ListTile(
                  leading: const Icon(Icons.alarm_rounded, color: brandColor),
                  title: Text(
                    timeText,
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w600),
                  ),
                  subtitle: note.isNotEmpty
                      ? Text(note, style: TextStyle(color: subTextColor))
                      : null,
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent.withOpacity(0.8),
                    ),
                    onPressed: () => provider.removeCustomReminder(index),
                  ),
                ),
              );
            }),

          const SizedBox(height: 12),

          // Add Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add_rounded, color: brandColor),
              label: const Text(
                "Add Custom Reminder",
                style:
                TextStyle(color: brandColor, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: brandColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: brandColor.withOpacity(0.04),
              ),
              onPressed: () => _showAddCustomReminderDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  // ───────── LANGUAGE TAB ─────────
  Widget _buildLanguageList(
      ThemeData theme,
      bool isDark,
      PreferencesProvider provider,
      ) {
    final languages = [
      {'code': 'en', 'name': 'English', 'native': 'English'},
      {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
      {'code': 'es', 'name': 'Spanish', 'native': 'Español'},
      {'code': 'fr', 'name': 'French', 'native': 'Français'},
      {'code': 'de', 'name': 'German', 'native': 'Deutsch'},
    ];

    return _buildSelectionList(
      theme: theme,
      isDark: isDark,
      items: languages,
      selectedKey: 'code',
      selectedValue: provider.languageCode,
      onSelect: (val) => provider.setLanguage(val),
      getLabel: (item) => item['name']!,
      getSubLabel: (item) => item['native']!,
      getIconText: (item) => item['code']!.toUpperCase(),
    );
  }

  // ───────── GENERIC SELECTION LIST ─────────
  Widget _buildSelectionList({
    required ThemeData theme,
    required bool isDark,
    required List<Map<String, String>> items,
    required String selectedKey,
    required String selectedValue,
    required Function(String) onSelect,
    required String Function(Map<String, String>) getLabel,
    required String Function(Map<String, String>) getIconText,
    String Function(Map<String, String>)? getSubLabel,
  }) {
    final cardColor = isDark ? const Color(0xFF111827) : Colors.white;
    final borderColor = theme.dividerColor.withOpacity(0.1);
    final textColor = theme.colorScheme.onSurface;
    const brandColor = Color(0xFF3B82F6);

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final item = items[i];
        final val = item[selectedKey]!;
        final isSelected = selectedValue == val;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: brandColor, width: 1.5)
                : Border.all(color: borderColor),
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
          child: ListTile(
            onTap: () => onSelect(val),
            leading: CircleAvatar(
              backgroundColor: brandColor.withOpacity(0.1),
              child: Text(
                getIconText(item),
                style: const TextStyle(
                  color: brandColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text(
              getLabel(item),
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
            subtitle: getSubLabel != null
                ? Text(
              getSubLabel(item),
              style: TextStyle(color: textColor.withOpacity(0.5)),
            )
                : null,
            trailing: isSelected
                ? const Icon(Icons.check_circle_rounded, color: brandColor)
                : null,
          ),
        );
      },
    );
  }

  // ───────── HELPERS ─────────
  Future<void> _pickReminderTime(
      BuildContext context, PreferencesProvider provider) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const brandColor = Color(0xFF3B82F6);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: provider.reminderTime,
      builder: (ctx, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
              primary: brandColor,
              onPrimary: Colors.white,
              surface: Color(0xFF111827),
              onSurface: Colors.white,
            )
                : const ColorScheme.light(
              primary: brandColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await provider.setReminderTime(picked);
    }
  }

  Future<void> _showAddCustomReminderDialog(BuildContext context) async {
    final provider = context.read<PreferencesProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const brandColor = Color(0xFF3B82F6);

    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
    final TextEditingController noteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        // Use StatefulBuilder to update only the dialog when time is picked
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF020617) : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: const Text("Add Custom Reminder"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time_rounded,
                        color: brandColor),
                    title: Text("Time: ${selectedTime.format(context)}"),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                        builder: (c, child) {
                          return Theme(
                            data: theme.copyWith(
                              colorScheme: isDark
                                  ? const ColorScheme.dark(
                                primary: brandColor,
                                onPrimary: Colors.white,
                                surface: Color(0xFF111827),
                                onSurface: Colors.white,
                              )
                                  : const ColorScheme.light(
                                primary: brandColor,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: Color(0xFF111827),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          selectedTime = picked;
                        });
                      }
                    },
                  ),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: "Note (optional)",
                      hintText: "Eg. Rent due...",
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                TextButton(
                  onPressed: () async {
                    await provider.addCustomReminder(
                        selectedTime, noteController.text.trim());
                    Navigator.pop(context);
                  },
                  child: const Text("Save",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

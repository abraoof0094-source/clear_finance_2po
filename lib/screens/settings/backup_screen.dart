import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For prefs backup only

import '../../models/transaction_model.dart';
import '../../models/category_model.dart';
import '../../models/forecast_item.dart';
import '../../providers/finance_provider.dart';
import '../../services/auth_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final AuthService _authService = AuthService();
  bool _isCloudEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (_authService.currentUser != null) {
      _isCloudEnabled = true;
    }
  }

  void _setLoading(bool value) {
    if (mounted) setState(() => _isLoading = value);
  }

  // ───────── DATA SERIALIZATION HELPERS ─────────

  // Creates a full JSON map of the current app state from the Provider (Isar)
  Future<Map<String, dynamic>> _serializeAppData() async {
    final provider = Provider.of<FinanceProvider>(context, listen: false);

    final transactions = provider.transactions.map((t) => t.toJson()).toList();
    final categories = provider.categories.map((c) => c.toJson()).toList();
    final forecastItems = provider.forecastItems.map((f) => f.toJson()).toList();

    // Also backup SharedPreferences (Settings)
    final prefs = await SharedPreferences.getInstance();
    final settings = {};
    // Only backup critical settings to avoid bloating
    final keysToSave = ['currency_symbol', 'theme_mode', 'is_app_lock_enabled'];
    for (var key in keysToSave) {
      if (prefs.containsKey(key)) {
        settings[key] = prefs.get(key);
      }
    }

    return {
      'version': 2, // Schema version
      'timestamp': DateTime.now().toIso8601String(),
      'transactions': transactions,
      'categories': categories,
      'forecast_items': forecastItems,
      'settings': settings,
    };
  }

  // Restores data from the JSON map into the Provider (Isar)
  Future<void> _restoreAppData(Map<String, dynamic> data) async {
    final provider = Provider.of<FinanceProvider>(context, listen: false);

    // 1. Categories
    if (data['categories'] != null) {
      final List list = data['categories'];
      for (var item in list) {
        // Check if ID exists to avoid duplicates or overwrite
        final cat = CategoryModel.fromJson(item);
        // Logic: Try to update if exists, else add.
        // For simplicity in backup restore, we might just put everything.
        // But FinanceProvider doesn't expose a raw 'putAll'.
        // We will loop and add/update.
        await provider.updateCategory(cat); // Helper that uses 'put' (upsert)
      }
    }

    // 2. Transactions
    if (data['transactions'] != null) {
      final List list = data['transactions'];
      for (var item in list) {
        final tx = TransactionModel.fromJson(item);
        await provider.addTransaction(tx); // This might trigger logic, be careful?
        // Actually, provider.addTransaction runs logic. We might want a "silent restore".
        // But since we don't have a silent bulk insert exposed yet, let's use what we have.
        // Ideally, you'd add a 'restoreTransactions' method to FinanceProvider to do bulk insert without logic.
      }
    }

    // 3. Forecast
    if (data['forecast_items'] != null) {
      final List list = data['forecast_items'];
      for (var item in list) {
        final f = ForecastItem.fromJson(item);
        await provider.updateForecastItem(f);
      }
    }

    // 4. Settings
    if (data['settings'] != null) {
      final Map settings = data['settings'];
      final prefs = await SharedPreferences.getInstance();
      settings.forEach((key, value) async {
        if (value is String) await prefs.setString(key as String, value);
        if (value is bool) await prefs.setBool(key as String, value);
        if (value is int) await prefs.setInt(key as String, value);
      });
    }

    // Reload UI
    await provider.loadData();
  }

  // ───────── ACTIONS ─────────

  Future<void> _exportCSV() async {
    _setLoading(true);
    try {
      final provider = Provider.of<FinanceProvider>(context, listen: false);
      final transactions = provider.transactions;

      if (transactions.isEmpty) throw "No transactions to export.";

      String csvData = "Date,Type,Category,Amount,Note\n";
      for (var tx in transactions) {
        final date = DateFormat('yyyy-MM-dd').format(tx.date);
        final category = tx.categoryName.replaceAll(',', ' ');
        final note = (tx.note ?? '').replaceAll(',', ' ');
        final type = tx.type.name.toUpperCase();
        csvData += "$date,$type,$category,${tx.amount},$note\n";
      }

      final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/clear_finance_report_$ts.csv');
      await file.writeAsString(csvData);

      await Share.shareXFiles([XFile(file.path)], text: 'Clear Finance CSV Report');
    } catch (e) {
      _showError("CSV Export failed: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _exportBackup() async {
    _setLoading(true);
    try {
      final data = await _serializeAppData();
      final jsonString = jsonEncode(data);

      final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/clear_finance_backup_$ts.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles([XFile(file.path)], text: 'Clear Finance Full Backup');
    } catch (e) {
      _showError("Export failed: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _importBackup() async {
    _setLoading(true);
    try {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json']
      );

      if (result == null || result.files.single.path == null) {
        _setLoading(false);
        return;
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> backup = jsonDecode(jsonString);

      if (!mounted) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Merge Backup?'),
          content: const Text('This will merge the backup file into your current data. Duplicates may occur if IDs match.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Merge')),
          ],
        ),
      );

      if (confirm != true) {
        _setLoading(false);
        return;
      }

      await _restoreAppData(backup);

      if (mounted) _showSuccess("Backup merged successfully!");

    } catch (e) {
      _showError("Import failed: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _uploadToCloud() async {
    final user = _authService.currentUser;
    if (user == null) {
      _showError("User not signed in.");
      return;
    }

    _setLoading(true);
    try {
      final data = await _serializeAppData();
      final jsonString = jsonEncode(data);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'backupData': jsonString,
        'lastUpdated': FieldValue.serverTimestamp(),
        'device': Platform.operatingSystem,
        'version': '2.0.0', // Updated version for Isar schema
        'email': user.email,
      }, SetOptions(merge: true));

      _showSuccess("Cloud Backup Successful!");
    } catch (e) {
      _showError("Upload failed: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _restoreFromCloud() async {
    final user = _authService.currentUser;
    if (user == null) return;

    _setLoading(true);
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (!doc.exists || doc.data() == null || !doc.data()!.containsKey('backupData')) {
        throw "No cloud backup found.";
      }

      final jsonString = doc.data()!['backupData'] as String;
      final Map<String, dynamic> cloudData = jsonDecode(jsonString);

      if (!mounted) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Restore from Cloud?'),
          content: const Text('This will merge the cloud data into your app.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Restore')),
          ],
        ),
      );

      if (confirm != true) {
        _setLoading(false);
        return;
      }

      await _restoreAppData(cloudData);

      if (mounted) _showSuccess("Restore Complete!");

    } catch (e) {
      _showError("Restore failed: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _signIn() async {
    _setLoading(true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        setState(() => _isCloudEnabled = true);
        _showSuccess("Welcome, ${user.displayName}!");
      }
    } catch (e) {
      _showError("Sign in failed: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text(
          'Are you sure you want to disconnect? Local data will remain on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (mounted) {
        setState(() => _isCloudEnabled = false);
        _showSuccess("Signed out successfully.");
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  // ───────── UI ─────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;
    final cardColor = theme.cardColor;
    final subTextColor = onBg.withOpacity(0.6);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: onBg),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Backups & Sync",
          style: TextStyle(color: onBg, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ───────── CLOUD SYNC CARD ─────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isCloudEnabled
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : [const Color(0xFF334155), const Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _isCloudEnabled ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isCloudEnabled ? "Cloud Sync Active" : "Cloud Sync Inactive",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isCloudEnabled
                            ? "Your data is synced with your Google account."
                            : "Connect to Google Drive to keep your data safe.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (!_isCloudEnabled)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Connect Google Drive",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      else
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _uploadToCloud,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(0.2),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                    ),
                                    child: const Text("Backup Now"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _restoreFromCloud,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text("Restore"),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: _signOut,
                              icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.white70),
                              label: const Text(
                                "Disconnect Account",
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          ],
                        )
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ───────── MANUAL EXPORT/IMPORT ─────────
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    "MANUAL BACKUPS",
                    style: TextStyle(
                      color: subTextColor.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildActionTile(
                        icon: Icons.table_chart_rounded,
                        color: Colors.greenAccent,
                        title: "Export to CSV",
                        subtitle: "For Excel or Google Sheets",
                        onTap: _exportCSV,
                        onBg: onBg,
                      ),
                      Divider(
                        color: onBg.withOpacity(0.05),
                        height: 1,
                        indent: 60,
                        endIndent: 20,
                      ),
                      _buildActionTile(
                        icon: Icons.code_rounded,
                        color: Colors.orangeAccent,
                        title: "Export JSON",
                        subtitle: "Full raw data backup",
                        onTap: _exportBackup,
                        onBg: onBg,
                      ),
                      Divider(
                        color: onBg.withOpacity(0.05),
                        height: 1,
                        indent: 60,
                        endIndent: 20,
                      ),
                      _buildActionTile(
                        icon: Icons.file_download_rounded,
                        color: Colors.blueAccent,
                        title: "Import JSON",
                        subtitle: "Restore from a file",
                        onTap: _importBackup,
                        onBg: onBg,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            )
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color onBg,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
          color: onBg,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: onBg.withOpacity(0.5),
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: onBg.withOpacity(0.2),
        size: 20,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; // Ensure this path is correct

class DataHubScreen extends StatefulWidget {
  const DataHubScreen({super.key});

  @override
  State<DataHubScreen> createState() => _DataHubScreenState();
}

class _DataHubScreenState extends State<DataHubScreen> {
  final AuthService _authService = AuthService();
  bool _isCloudEnabled = false;

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    if (_authService.currentUser != null) {
      _isCloudEnabled = true;
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
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
            "Data & Sync",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Status Card
            _buildStatusCard(),

            const SizedBox(height: 32),

            // 2. Cloud Section
            const Text(
                "Cloud Backup",
                style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0)
            ),
            const SizedBox(height: 12),

            if (!_isCloudEnabled) _buildCloudUpsell(),

            if (_isCloudEnabled) ...[
              _buildMenuItem(
                icon: Icons.sync_rounded,
                title: "Sync Now",
                subtitle: "Last synced: Just now",
                color: Colors.blueAccent,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Syncing data... (Coming Soon)"))
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildMenuItem(
                icon: Icons.logout_rounded,
                title: "Sign Out",
                subtitle: "Disable sync & clear local cache",
                color: Colors.orangeAccent,
                onTap: () async {
                  await _authService.signOut();
                  setState(() => _isCloudEnabled = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Signed out. Data is now local only."))
                    );
                  }
                },
              ),
            ],

            const SizedBox(height: 32),

            // 3. Local Section
            const Text(
                "Device Storage",
                style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0)
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.upload_file_rounded,
              title: "Export Backup",
              subtitle: "Save .bak file to device",
              color: Colors.white,
              onTap: () {
                // Local backup logic
              },
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              icon: Icons.download_rounded,
              title: "Import Backup",
              subtitle: "Restore from .bak file",
              color: Colors.white,
              onTap: () {
                // Local restore logic
              },
            ),

            const SizedBox(height: 32),

            // 4. Danger Section
            const Text(
                "Danger Zone",
                style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0)
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: ListTile(
                onTap: () {
                  // Delete logic
                },
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 20),
                ),
                title: const Text("Reset App", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                subtitle: const Text("Delete all transactions & settings", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    // Display user email if logged in
    final String statusText = _isCloudEnabled
        ? "Synced as ${_authService.currentUser?.email}"
        : "Local Storage Only";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: _isCloudEnabled
            ? const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: _isCloudEnabled ? null : Border.all(color: Colors.white10),
        boxShadow: [
          if (_isCloudEnabled)
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isCloudEnabled ? Icons.cloud_done_rounded : Icons.sd_storage_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isCloudEnabled ? "Cloud Sync Active" : "Local Storage Only",
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _isCloudEnabled
                ? "Your data is securely backed up."
                : "Data is stored on this device only.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
          ),
          if (_isCloudEnabled) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Text(
                _authService.currentUser?.email ?? "",
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildCloudUpsell() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_upload_rounded, color: Colors.blueAccent, size: 28),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Enable Sync", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Free backup & multi-device access", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () async {
                // 1. Show Feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Connecting to Google...")),
                );

                // 2. Call Service
                final user = await _authService.signInWithGoogle();

                // 3. Handle Result
                if (user != null) {
                  setState(() {
                    _isCloudEnabled = true;
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Welcome, ${user.displayName}!")),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Sign in cancelled.")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text("Turn On Sync", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[600], size: 20),
      ),
    );
  }
}

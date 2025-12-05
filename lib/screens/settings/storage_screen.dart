import 'package:flutter/material.dart';

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

            _storageTile(
              icon: Icons.file_upload_outlined,
              title: 'export backup',
              subtitle: '.bak file with your transactions and settings',
              color: const Color(0xFF3B82F6),
              onTap: _exportBackup,
            ),
            const SizedBox(height: 10),

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
            Navigator.pop(context);
            widget.onConfirm();
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
              : const Text('Delete Data',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

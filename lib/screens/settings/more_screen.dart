import 'package:flutter/material.dart';

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
          const Icon(Icons.email_outlined,
              size: 48, color: Color(0xFF3B82F6)),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
            ),
            child: const Text('Send Email',
                style: TextStyle(color: Colors.white)),
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
            child: const Icon(Icons.account_balance_wallet,
                color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          const Text(
            'clear finance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
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

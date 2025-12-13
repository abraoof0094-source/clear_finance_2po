import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/welcome_service.dart';
import '../../providers/user_profile_provider.dart';
import '../home/home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeWelcome(BuildContext context) async {
    final welcomeService = WelcomeService();
    await welcomeService.completeWelcome();

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _goToProfilePage() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          children: [
            _IntroPage(onGetStarted: _goToProfilePage),
            _ProfileOnboardingPage(
              onSkip: () => _completeWelcome(context),
              onDone: () => _completeWelcome(context),
            ),
          ],
        ),
      ),
    );
  }
}

// PAGE 1 – welcome UI
class _IntroPage extends StatelessWidget {
  final VoidCallback onGetStarted;

  const _IntroPage({required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onBackground;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // logo tile
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              size: 50,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 40),

          const Text(
            "clear finance",
            style: TextStyle(
              color: Color(0xFF3B82F6),
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "Your money, simplified.",
            style: TextStyle(
              color: onBg.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            "Track spending, manage budgets,\nand reach your financial goals.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onBg.withOpacity(0.6),
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 60),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onGetStarted,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Get Started",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Column(
            children: const [
              _FeatureItem(
                icon: Icons.speed_rounded,
                text: "Quick transaction entry",
              ),
              SizedBox(height: 12),
              _FeatureItem(
                icon: Icons.pie_chart_rounded,
                text: "Smart budget tracking",
              ),
              SizedBox(height: 12),
              _FeatureItem(
                icon: Icons.insights_rounded,
                text: "Financial insights",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// PAGE 2 – profile info
class _ProfileOnboardingPage extends StatefulWidget {
  final VoidCallback onSkip;
  final VoidCallback onDone;

  const _ProfileOnboardingPage({
    required this.onSkip,
    required this.onDone,
  });

  @override
  State<_ProfileOnboardingPage> createState() => _ProfileOnboardingPageState();
}

class _ProfileOnboardingPageState extends State<_ProfileOnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProfileProvider>().profile;
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_nameController.text.trim().isNotEmpty ||
        _emailController.text.trim().isNotEmpty ||
        _phoneController.text.trim().isNotEmpty) {
      context.read<UserProfileProvider>().updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );
    }
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onBackground;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Make it yours",
                        style: TextStyle(
                          color: onBg,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "These details only help personalize clear finance. "
                            "You can skip this and add it later in Settings.",
                        style: TextStyle(
                          color: onBg.withOpacity(0.7),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 28),

                      _buildFieldLabel("Name", onBg),
                      _buildTextField(
                        controller: _nameController,
                        hint: "What should we call you?",
                        theme: theme,
                        onBg: onBg,
                      ),

                      const SizedBox(height: 18),

                      _buildFieldLabel("Email (optional)", onBg),
                      _buildTextField(
                        controller: _emailController,
                        hint: "For backups or support",
                        keyboardType: TextInputType.emailAddress,
                        theme: theme,
                        onBg: onBg,
                      ),

                      const SizedBox(height: 18),

                      _buildFieldLabel("Phone (optional)", onBg),
                      _buildTextField(
                        controller: _phoneController,
                        hint: "For recovery or support",
                        keyboardType: TextInputType.phone,
                        theme: theme,
                        onBg: onBg,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // bottom bar
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    TextButton(
                      onPressed: widget.onSkip,
                      child: Text(
                        "Skip for now",
                        style: TextStyle(
                          color: onBg.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding:
                          const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text, Color onBg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: onBg.withOpacity(0.7),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required ThemeData theme,
    required Color onBg,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: onBg.withOpacity(0.06)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: onBg, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: onBg.withOpacity(0.4)),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

// feature item now uses theme.cardColor / onBg
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onBackground;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF3B82F6),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: onBg.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

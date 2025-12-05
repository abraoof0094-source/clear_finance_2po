import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../services/onboarding_service.dart';
import '../../models/salary_profile.dart'; // Make sure to import this
import '../home_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _controller = PageController();
  final TextEditingController _salaryController = TextEditingController();

  // Temporary state to hold onboarding data before saving
  double? _monthlySalary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        children: [
          _buildWelcomePage(),
          _buildSalaryPage(),
          _buildInvestmentPage(),
        ],
      ),
    );
  }

  // PAGE 1: Welcome
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.rocket_launch_rounded, size: 80, color: Color(0xFF3B82F6)),
          const SizedBox(height: 32),
          const Text(
            "clear finance",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Stop wondering where your money went.\nStart telling it where to go.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => _controller.nextPage(
                duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              "Get Started",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // PAGE 2: Salary Input
  Widget _buildSalaryPage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "First things first.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "What is your monthly\ntake-home income?",
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _salaryController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              prefixText: "₹ ",
              prefixStyle: TextStyle(color: Colors.grey, fontSize: 32),
              hintText: "0",
              hintStyle: TextStyle(color: Colors.white24),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_salaryController.text.isNotEmpty) {
                  setState(() {
                    _monthlySalary = double.tryParse(_salaryController.text) ?? 0.0;
                  });
                  _controller.nextPage(
                      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Next", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // PAGE 3: Investment Goal
  Widget _buildInvestmentPage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pay yourself first.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "How much do you want to\ninvest each month?",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),

          // Investment Options
          _investmentOption(
            label: "Aggressive (30%)",
            subtitle: "Build wealth fast",
            percentage: 30,
            onTap: () => _finishOnboarding(30),
          ),
          const SizedBox(height: 16),
          _investmentOption(
            label: "Balanced (20%)",
            subtitle: "Recommended for most",
            percentage: 20,
            onTap: () => _finishOnboarding(20),
          ),
          const SizedBox(height: 16),
          _investmentOption(
            label: "Conservative (10%)",
            subtitle: "Good start",
            percentage: 10,
            onTap: () => _finishOnboarding(10),
          ),
          const SizedBox(height: 16),

          // Skip option
          Center(
            child: TextButton(
              onPressed: () => _finishOnboarding(0),
              child: const Text("I'll set this later", style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _investmentOption({
    required String label,
    required String subtitle,
    required double percentage,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _finishOnboarding(double percentage) async {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final onboardingService = OnboardingService();

    // 1. Create the profile object
    // Note: We use 'percentage' mode for onboarding simplicity
    final profile = SalaryProfile(
      monthlySalary: _monthlySalary,
      investmentGoalPercentage: percentage,
      investmentMode: InvestmentMode.percentage,
      investmentGoalAmount: 0, // Can be calculated or left 0 for now
    );

    // 2. Save to DB via Provider
    await provider.updateSalaryProfile(profile);

    // 3. Mark onboarding as complete in SharedPrefs
    await onboardingService.completeOnboarding();

    // 4. Navigate to Home
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }
}

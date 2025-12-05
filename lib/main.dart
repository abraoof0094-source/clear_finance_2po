import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/finance_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'utils/app_theme.dart';
import 'services/onboarding_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FinanceProvider(), // Don't call loadData() here immediately
      child: const ClearFinanceApp(),
    ),
  );
}

class ClearFinanceApp extends StatelessWidget {
  const ClearFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'clear finance',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      home: const _RootDecider(),
    );
  }
}

class _RootDecider extends StatefulWidget {
  const _RootDecider({super.key});

  @override
  State<_RootDecider> createState() => _RootDeciderState();
}

class _RootDeciderState extends State<_RootDecider> {
  bool _isLoading = true;
  bool _hasCompletedOnboarding = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. Load Data from Disk (Critical Step)
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    await provider.loadData();

    // 2. Check Onboarding Status
    final service = OnboardingService();
    final done = await service.isOnboardingComplete();

    // 3. Check if critical data actually exists (Safety Check)
    // Even if flag is true, if data is missing (e.g. cleared cache), force onboarding
    final isDataValid = provider.salaryProfile != null;

    if (mounted) {
      setState(() {
        // Only consider onboarding complete if flag is TRUE AND data exists
        _hasCompletedOnboarding = done && isDataValid;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A), // Match app theme
        body: Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    if (_hasCompletedOnboarding) {
      return const HomeScreen();
    } else {
      return const OnboardingFlow();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'providers/finance_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/preferences_provider.dart';

import 'screens/home/home_screen.dart';
import 'screens/welcome/welcome_screen.dart';
import 'utils/app_theme.dart';
import 'services/welcome_service.dart';
import 'services/database_service.dart';
import 'widgets/app_lock_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 🚀 Initialize Isar Database
  final dbService = DatabaseService();
  await dbService.db; // Wait for open() to finish before launching app
  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => PreferencesProvider()),
      ],
      child: const ClearFinanceApp(),
    ),
  );
}

class ClearFinanceApp extends StatelessWidget {
  const ClearFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'clear finance',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const AppLockGate(
            child: _RootDecider(),
          ),
        );
      },
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
  bool _hasSeenWelcome = false;

  @override
  void initState() {
    super.initState();
    // 🛠️ FIX: Move initialization to after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initApp();
    });
  }

  Future<void> _initApp() async {
    // FinanceProvider loads categories, transactions, etc.
    final financeProvider =
    Provider.of<FinanceProvider>(context, listen: false);

    // This call notifies listeners, which is safe inside this callback
    await financeProvider.loadData();

    final service = WelcomeService();
    final done = await service.isWelcomeComplete();

    if (mounted) {
      setState(() {
        _hasSeenWelcome = done;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 UPDATED: Minimal Splash Screen with Linear Bar
    if (_isLoading) {
      final theme = Theme.of(context);
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. App Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),

              // 2. Subtle Linear Progress Bar
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    // Active color = App Primary
                    color: theme.colorScheme.primary,
                    // Background = Primary with low opacity
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasSeenWelcome) {
      return const WelcomeScreen();
    }

    return const HomeScreen();
  }
}

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

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
    // While loading, show nothing special to avoid a flashing spinner
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (!_hasSeenWelcome) {
      return const WelcomeScreen();
    }

    return const HomeScreen();
  }
}

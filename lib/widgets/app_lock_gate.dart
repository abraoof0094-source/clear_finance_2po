// lib/widgets/app_lock_gate.dart
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../providers/preferences_provider.dart';

class AppLockGate extends StatefulWidget {
  final Widget child;
  const AppLockGate({super.key, required this.child});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate>
    with WidgetsBindingObserver {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _authenticated = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = context.read<PreferencesProvider>();
      prefs.addListener(_onPrefsChanged);

      if (prefs.isAppLockEnabled) {
        _authenticate(); // auto‑prompt at app start
      } else {
        if (!mounted) return;
        setState(() => _authenticated = true);
      }
    });
  }

  void _onPrefsChanged() {
    if (!mounted) return;
    final prefs = context.read<PreferencesProvider>();

    if (!prefs.isAppLockEnabled) {
      setState(() => _authenticated = true);
    } else {
      setState(() => _authenticated = false);
      _authenticate(); // prompt when user turns it ON
    }
  }

  Future<void> _authenticate() async {
    if (!mounted || _isAuthenticating) return;

    final prefs = context.read<PreferencesProvider>();
    if (!prefs.isAppLockEnabled) {
      setState(() => _authenticated = true);
      return;
    }

    _isAuthenticating = true;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      debugPrint('canCheckBiometrics=$canCheck, isSupported=$isSupported');

      if (!canCheck && !isSupported) {
        if (!mounted) return;
        // No biometrics / device lock → just show the app
        setState(() => _authenticated = true);
        return;
      }

      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Unlock Clear Finance',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (!mounted) return;
      setState(() => _authenticated = didAuthenticate);
    } catch (e) {
      debugPrint('local_auth error: $e');
      if (!mounted) return;
      setState(() => _authenticated = false);
    } finally {
      _isAuthenticating = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final prefs = context.read<PreferencesProvider>();
    if (!prefs.isAppLockEnabled || !mounted) return;

    if (state == AppLifecycleState.resumed && !_authenticated) {
      _authenticate(); // auto‑prompt on resume
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<PreferencesProvider>().removeListener(_onPrefsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesProvider>();

    // Lock OFF or already unlocked → show app
    if (!prefs.isAppLockEnabled || _authenticated) {
      return widget.child;
    }

    // Locked: show an empty scaffold with same background as app
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
    );
  }
}

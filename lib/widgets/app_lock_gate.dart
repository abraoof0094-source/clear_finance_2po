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

    // 1. If Lock is OFF or user is ALREADY authenticated -> Show the App
    if (!prefs.isAppLockEnabled || _authenticated) {
      return widget.child;
    }

    // 2. If Locked -> Show "Locked" Screen with a Button
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Big Lock Icon
            Icon(
              Icons.lock_outline_rounded,
              size: 64,
              color: onBg.withOpacity(0.5),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              "Clear Finance is Locked",
              style: TextStyle(
                color: onBg,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              "Please authenticate to continue",
              style: TextStyle(
                color: onBg.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // 🟢 THE NEW BUTTON
            // This allows the user to manually trigger the prompt
            // if the auto-prompt failed or was dismissed.
            ElevatedButton.icon(
              onPressed: _authenticate, // <--- Calls the same function
              icon: const Icon(Icons.fingerprint_rounded),
              label: const Text("Tap to Unlock"),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

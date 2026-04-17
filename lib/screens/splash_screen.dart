import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:allo_secours/config/app_colors.dart';
import 'package:allo_secours/providers/auth_provider.dart';
import 'package:allo_secours/providers/location_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // addPostFrameCallback garantit que le widget tree ET le router GetX
    // sont pleinement initialisés avant toute navigation
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  Future<void> _checkAuth() async {
    // Délai minimal pour l'animation du splash
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    await auth.initialize();

    if (!mounted) return;

    if (auth.isAuthenticated) {
      context.read<LocationProvider>().getCurrentLocation();
    }
    // Navigator standard : fonctionne depuis un home: sans pile GetX
    Navigator.of(context).pushNamedAndRemoveUntil(
      auth.isAuthenticated ? '/' : '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                size: 72,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Allô Secours',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre santé, notre priorité',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}

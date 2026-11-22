import 'package:flutter/material.dart';
import 'api_service.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() => runApp(const CourtBookApp());

class CourtBookApp extends StatelessWidget {
  const CourtBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CourtBook',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<Widget> _decideNextScreen() async {
    final token = await ApiService.getToken();
    if (token != null) {
      final r = await ApiService.profile();
      if (r.ok) return const DashboardScreen();
      if (r.status == 401) await ApiService.clearToken();
    }
    return const LoginScreen();
  }

  Future<void> _checkSession() async {
    // Run the session check and a short minimum delay together,
    // so the splash screen is visible for at least ~1.2 seconds.
    final results = await Future.wait<dynamic>([
      _decideNextScreen(),
      Future.delayed(const Duration(milliseconds: 1200)),
    ]);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => results[0] as Widget),
    );
  }

  @override
    Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sage,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                LogoTile(size: 104),
                SizedBox(height: 24),
                Text(
                  'CourtBook',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    color: AppColors.deepGreen,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Court booking made simple',
                  style: TextStyle(fontSize: 15, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 72,
            child: Column(
              children: const [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.green,
                    backgroundColor: Color(0xFFCFE0D5),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Checking your session...',
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../api_service.dart';
import '../theme.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;

    // Validation messages appear at the bottom, like the server errors.
    if (email.isEmpty) {
      showAppMessage(context, 'Please enter your email.');
      return;
    }
    if (password.isEmpty) {
      showAppMessage(context, 'Please enter your password.');
      return;
    }

    setState(() => _loading = true);
    final r = await ApiService.login(email, password);
    if (!mounted) return;
    setState(() => _loading = false);
    if (r.ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      showAppMessage(context, r.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(28, topInset + 48, 28, 48),
              decoration: const BoxDecoration(
                color: AppColors.deepGreen,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LogoTile(size: 60),
                  SizedBox(height: 20),
                  Text(
                    'CourtBook',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sign in to book your next game.',
                    style: TextStyle(fontSize: 15, color: Color(0xFFBFD6C8)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
              child: Form(
                child: Column(
                  children: [
                    LabeledField(
                      controller: _email,
                      label: 'Email',
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),
                    LabeledField(
                      controller: _password,
                      label: 'Password',
                      hint: 'Enter your password',
                      obscure: _obscure,
                      suffix: IconButton(
                        tooltip: _obscure ? 'Show password' : 'Hide password',
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.muted,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: 26),
                    PrimaryButton(
                      label: 'Login',
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No account yet?',
                          style: TextStyle(color: AppColors.muted, fontSize: 14),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.green,
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          ),
                          child: const Text('Register'),
                        ),
                      ],
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
}
import 'package:flutter/material.dart';
import '../api_service.dart';
import '../theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    final confirm = _confirm.text;

    // Validation messages appear at the bottom, like the server errors.
    if (name.isEmpty) {
      showAppMessage(context, 'Please enter your name.');
      return;
    }
    if (email.isEmpty) {
      showAppMessage(context, 'Please enter your email.');
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      showAppMessage(context, 'Please enter a valid email address.');
      return;
    }
    if (password.isEmpty) {
      showAppMessage(context, 'Please enter a password.');
      return;
    }
    if (password.length < 8) {
      showAppMessage(context, 'Password must be at least 8 characters.');
      return;
    }
    if (confirm != password) {
      showAppMessage(context, 'Passwords do not match.');
      return;
    }

    setState(() => _loading = true);
    final r = await ApiService.register(name, email, password, confirm);
    if (!mounted) return;
    setState(() => _loading = false);
    showAppMessage(context, r.message, success: r.ok);
    if (r.ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.green,
                    padding: EdgeInsets.zero,
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Back to login'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: AppColors.deepGreen,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join as a player and start booking courts.',
                  style: TextStyle(fontSize: 15, color: AppColors.muted),
                ),
                const SizedBox(height: 24),
                LabeledField(
                  controller: _name,
                  label: 'Name',
                  hint: 'Your full name',
                ),
                const SizedBox(height: 18),
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
                  hint: 'At least 8 characters',
                  obscure: true,
                ),
                const SizedBox(height: 18),
                LabeledField(
                  controller: _confirm,
                  label: 'Confirm password',
                  hint: 'Repeat your password',
                  obscure: true,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Create account',
                  loading: _loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
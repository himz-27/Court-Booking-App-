import 'package:flutter/material.dart';
import '../api_service.dart';
import '../theme.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await ApiService.profile();
    if (!mounted) return;
    if (r.status == 401) {
      await ApiService.clearToken();
      if (!mounted) return;
      _goToLogin();
      return;
    }
    setState(() {
      _loading = false;
      if (r.ok) {
        _data = r.data;
        _error = null;
      } else {
        _error = r.message;
      }
    });
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    _goToLogin();
  }

  String _badge(String role) => role == 'court_admin' ? 'COURT ADMIN' : 'PLAYER';
  String _roleLabel(String role) =>
      role == 'court_admin' ? 'Court Admin' : 'Player';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _header(),
                  _body(),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: Color(0xFFE6C5C2), width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    final topInset = MediaQuery.of(context).padding.top;
    final title = _data?['app_title']?.toString() ?? 'CourtBook';
    final hasData = _data != null;

    // Layout numbers. The welcome card sits in the normal flow (it never
    // overlaps the title, however long the message is). The green block is
    // drawn behind it and ends [overlap] px below the card's top edge.
    const logoSize = 36.0;
    const gap = 32.0; // space between the title row and the card
    const overlap = 56.0; // how far the green block reaches behind the card
    final titleBottom = topInset + 20 + logoSize;
    final greenHeight = hasData ? titleBottom + gap + overlap : titleBottom + 28;

    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: greenHeight,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.deepGreen,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(24, topInset + 20, 24, 0),
                child: Row(
                  children: [
                    const LogoTile(size: logoSize),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasData)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, gap, 20, 0),
                  child: _welcomeCard(),
                )
              else
                const SizedBox(height: 28),
            ],
          ),
        ],
      ),
    );
  }

  Widget _welcomeCard() {
    final user = _data!['user'] as Map<String, dynamic>;
    final name = user['name'].toString();
    final role = user['role'].toString();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F3D2E),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.green,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _data!['message'].toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.lime,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    _badge(role),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B2A00),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _load();
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    final user = _data!['user'] as Map<String, dynamic>;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'ACCOUNT DETAILS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: AppColors.muted,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _row(Icons.person_outline, 'Name', user['name'].toString()),
                _divider(),
                _row(Icons.mail_outline, 'Email', user['email'].toString()),
                _divider(),
                _row(Icons.verified_user_outlined, 'Role',
                    _roleLabel(user['role'].toString())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: Divider(height: 1, color: Color(0xFFEAF0EC)),
      );

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.green, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
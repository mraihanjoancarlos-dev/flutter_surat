// lib/screens/login_screen.dart
// UI mengikuti desain web SIMFARS: dark theme, gradient biru-ungu, card glassmorphism

import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure  = true;
  bool _loading  = false;
  String _error  = '';

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  Future<void> _login() async {
    setState(() { _error = ''; _loading = true; });

    try {
      final res = await ApiService.login(
        _userCtrl.text.trim(),
        _passCtrl.text.trim(),
      );

      if (res['status'] == 'success') {
        await ApiService.saveToken(res['data']['token']);
        await ApiService.saveAdmin(res['data']['admin']);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        setState(() { _error = res['message'] ?? 'Login gagal'; });
      }
    } catch (e) {
      setState(() { _error = 'Tidak dapat terhubung ke server. Cek koneksi kamu.'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Background blobs — sama dengan web
          Positioned(
            top: -80, left: -80,
            child: _blob(300, AppColors.accent.withOpacity(0.15)),
          ),
          Positioned(
            bottom: -80, right: -80,
            child: _blob(280, AppColors.accent2.withOpacity(0.15)),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Badge ──────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.accent.withOpacity(0.25)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_outlined, size: 14, color: AppColors.accent),
                            SizedBox(width: 6),
                            Text(
                              'Sistem Arsip Digital',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Judul ──────────────────────────────
                      ShaderMask(
                        shaderCallback: (b) => const LinearGradient(
                          colors: [Colors.white, AppColors.accent2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(b),
                        child: const Text(
                          'SIMFARS',
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Sistem Informasi Manajemen Surat modern untuk mengelola surat masuk dan surat keluar secara cepat, aman, dan terintegrasi.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.7,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Feature list ──────────────────────
                      ...[
                        (Icons.mark_email_read_outlined, 'Surat Masuk', 'Kelola arsip surat masuk dengan rapi'),
                        (Icons.send_outlined, 'Surat Keluar', 'Pencatatan dan tracking surat keluar'),
                        (Icons.bar_chart_rounded, 'Dashboard Statistik', 'Laporan dan monitoring realtime'),
                      ].map((e) => _featureItem(e.$1, e.$2, e.$3)),

                      const SizedBox(height: 32),

                      // ── Login Card ─────────────────────────
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selamat Datang 👋',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Silakan login untuk masuk ke dashboard administrator',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Error box
                            if (_error.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(_error,
                                        style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Username
                            const Text('Username',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _userCtrl,
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: const InputDecoration(
                                hintText: 'Masukkan username',
                                prefixIcon: Icon(Icons.person_outline, color: AppColors.textMuted),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Password
                            const Text('Password',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _passCtrl,
                              obscureText: _obscure,
                              style: const TextStyle(color: AppColors.textPrimary),
                              onSubmitted: (_) => _login(),
                              decoration: InputDecoration(
                                hintText: 'Masukkan password',
                                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: AppColors.textMuted,
                                  ),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Tombol Login
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.accent, AppColors.accent2],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent.withOpacity(0.35),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    )
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 20, height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2))
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.login_rounded, size: 18),
                                            SizedBox(width: 8),
                                            Text('Masuk ke Dashboard',
                                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                          ],
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Info default account
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
                                  SizedBox(width: 8),
                                  Text.rich(
                                    TextSpan(
                                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                      children: [
                                        TextSpan(text: 'Username: '),
                                        TextSpan(text: 'admin ',
                                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                                        TextSpan(text: '  Password: '),
                                        TextSpan(text: 'password',
                                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
    ),
    child: BackdropFilter(
      filter: ColorFilter.mode(color, BlendMode.srcOver),
      child: const SizedBox.shrink(),
    ),
  );

  Widget _featureItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withOpacity(0.2),
                  AppColors.accent2.withOpacity(0.2),
                ],
              ),
            ),
            child: Icon(icon, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
              Text(subtitle, style: const TextStyle(
                color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }
}

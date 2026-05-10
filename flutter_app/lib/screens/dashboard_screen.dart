// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _adminNama;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final admin = await ApiService.getAdmin();
      final res   = await ApiService.getDashboard();
      if (res['status'] == 'success') {
        setState(() {
          _data      = res['data'];
          _adminNama = admin?['nama'] ?? 'Admin';
          _loading   = false;
        });
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Yakin ingin keluar dari akun ini?',
          style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.clearSession();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard', style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
            Text('Selamat datang, ${_adminNama ?? ''}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: _load,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.accent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Statistik Cards ────────────────────
                    const Text('Statistik', style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: 1,
                    )),
                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        _statCard('Surat Masuk', '${_data?['statistik']?['total_surat_masuk'] ?? 0}',
                          Icons.mark_email_read_outlined, AppColors.accent),
                        _statCard('Surat Keluar', '${_data?['statistik']?['total_surat_keluar'] ?? 0}',
                          Icons.send_outlined, AppColors.accent2),
                        _statCard('Belum Diproses', '${_data?['statistik']?['sm_belum_diproses'] ?? 0}',
                          Icons.pending_outlined, Colors.amber),
                        _statCard('Draft', '${_data?['statistik']?['sk_draft'] ?? 0}',
                          Icons.drafts_outlined, Colors.teal),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Surat Masuk Terbaru ────────────────
                    _sectionHeader('Surat Masuk Terbaru'),
                    const SizedBox(height: 10),
                    ...(_data?['surat_masuk_terbaru'] as List? ?? [])
                        .map((s) => _suratMasukCard(s)),

                    const SizedBox(height: 24),

                    // ── Surat Keluar Terbaru ───────────────
                    _sectionHeader('Surat Keluar Terbaru'),
                    const SizedBox(height: 10),
                    ...(_data?['surat_keluar_terbaru'] as List? ?? [])
                        .map((s) => _suratKeluarCard(s)),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.0,
          )),
          const SizedBox(height: 2),
          Text(title,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Text(title,
    style: const TextStyle(
      color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 15));

  Widget _suratMasukCard(Map s) {
    final status = s['status'] ?? '';
    final kep    = s['kepentingan'] ?? 'Biasa';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.mark_email_read_outlined, color: AppColors.accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['perihal'] ?? '', style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(s['asal_surat'] ?? '', style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _badge(status, statusColor(status)),
              const SizedBox(height: 4),
              _badge(kep, kepentinganColor(kep)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _suratKeluarCard(Map s) {
    final status = s['status'] ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent2.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.send_outlined, color: AppColors.accent2, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['perihal'] ?? '', style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(s['tujuan_surat'] ?? '', style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          _badge(status, statusColor(status)),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
  );
}

// ── Helper Functions ───────────────────────────────────────
Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'diproses': return Colors.blue;
    case 'selesai':  return Colors.green;
    case 'draft':    return Colors.grey;
    default:         return Colors.orange;
  }
}

Color kepentinganColor(String kep) {
  switch (kep.toLowerCase()) {
    case 'penting':  return Colors.redAccent;
    case 'segera':   return Colors.orange;
    default:         return Colors.teal;
  }
}
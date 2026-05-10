// lib/screens/main_screen.dart
// Bottom navigation: Dashboard, Surat Masuk, Surat Keluar, Profil

import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import 'surat_masuk_screen.dart';
import 'surat_keluar_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _idx = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    SuratMasukScreen(),
    SuratKeluarScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.accent.withOpacity(0.15),
          selectedIndex: _idx,
          onDestinationSelected: (i) => setState(() => _idx = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: AppColors.accent),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.mark_email_read_outlined),
              selectedIcon: Icon(Icons.mark_email_read, color: AppColors.accent),
              label: 'Surat Masuk',
            ),
            NavigationDestination(
              icon: Icon(Icons.send_outlined),
              selectedIcon: Icon(Icons.send, color: AppColors.accent),
              label: 'Surat Keluar',
            ),
          ],
        ),
      ),
    );
  }
}

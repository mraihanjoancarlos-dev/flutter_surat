// lib/core/theme.dart
// Warna & style yang sama persis dengan web SIMFARS

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Background utama (sama dengan --bg-dark di web)
  static const bgDark    = Color(0xFF0A0F1E);
  static const bgCard    = Color(0xFF111827);
  static const bgCard2   = Color(0xFF1A2235);

  // Accent (sama dengan --accent di web)
  static const accent    = Color(0xFF4F8EF7);
  static const accent2   = Color(0xFF7C5EF5);

  // Text
  static const textPrimary   = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B8C8);
  static const textMuted     = Color(0xFF6B7A99);

  // Border
  static const border    = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

  // Status badge
  static const statusBelum    = Color(0xFF6B7A99);
  static const statusProses   = Color(0xFFF59E0B);
  static const statusSelesai  = Color(0xFF10B981);
  static const statusDraft    = Color(0xFF6B7A99);
  static const statusTerkirim = Color(0xFF10B981);
  static const statusBatal    = Color(0xFFEF4444);

  // Kepentingan
  static const kepBiasa      = Color(0xFF10B981);
  static const kepPenting    = Color(0xFFF59E0B);
  static const kepSPenting   = Color(0xFFEF4444);
  static const kepRahasia    = Color(0xFF8B5CF6);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.accent2,
      surface: AppColors.bgCard,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgCard,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgCard2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      hintStyle: const TextStyle(color: AppColors.textMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

// Warna status badge
Color statusColor(String status) {
  switch (status) {
    case 'Selesai':
    case 'Terkirim':
      return AppColors.statusSelesai;
    case 'Sedang Diproses':
    case 'Draft':
      return AppColors.statusProses;
    case 'Dibatalkan':
      return AppColors.statusBatal;
    default:
      return AppColors.statusBelum;
  }
}

Color kepentinganColor(String k) {
  switch (k) {
    case 'Sangat Penting':
      return AppColors.kepSPenting;
    case 'Penting':
      return AppColors.kepPenting;
    case 'Rahasia':
      return AppColors.kepRahasia;
    default:
      return AppColors.kepBiasa;
  }
}

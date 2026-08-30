// 📁 lib/core/constants/app_colors.dart
// PURPOSE: The ONE palette for the whole app. Nothing else defines colors.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ============================================================
  // Brand — teal reads as trust / stability, common in finance apps.
  // ============================================================

  static const Color primary = Color(0xFF0F766E);
  static const Color primaryDark = Color(0xFF115E59);
  static const Color primaryDarker = Color(0xFF0B4F4A);
  static const Color primaryLight = Color(0xFFCCFBF1);

  /// Gradient used by the hero balance card on the home screen.
  static const List<Color> heroGradient = [
    Color(0xFF0F766E),
    Color(0xFF0B4F4A),
  ];

  // ============================================================
  // Financial meaning — green = money coming in, red = money going out.
  // ============================================================

  /// Someone owes you money (credit).
  static const Color credit = Color(0xFF16A34A);
  static const Color creditLight = Color(0xFFDCFCE7);

  /// You owe someone money (debit).
  static const Color debit = Color(0xFFDC2626);
  static const Color debitLight = Color(0xFFFEE2E2);

  /// Balance is exactly zero — nothing is owed either way.
  static const Color settled = Color(0xFF64748B);
  static const Color settledLight = Color(0xFFF1F5F9);

  static const Color warning = Color(0xFFD97706);
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // ============================================================
  // Light theme
  // ============================================================

  static const Color lightBackground = Color(0xFFF6F8FA);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceAlt = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // ============================================================
  // Dark theme
  // ============================================================

  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF151E2E);
  static const Color darkSurfaceAlt = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF283549);

  static const Color white = Colors.white;

  /// Picks the right colour for a balance: green if positive (they owe you),
  /// red if negative (you owe them), grey when it is exactly zero.
  static Color forBalance(double balance) {
    if (balance == 0) return settled;
    return balance > 0 ? credit : debit;
  }
}

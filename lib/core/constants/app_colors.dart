import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ============================================================
  // Brand
  // ============================================================

  /// Main Maly brand color.
  /// Represents trust, balance, and financial stability.
  static const Color primary = Color(0xFF0F766E);

  /// Slightly darker primary for pressed/strong states.
  static const Color primaryDark = Color(0xFF115E59);

  /// Lighter primary for backgrounds, selected states, etc.
  static const Color primaryLight = Color(0xFFCCFBF1);

  // ============================================================
  // Financial / Transaction Colors
  // ============================================================

  /// Someone owes you money.
  /// Credit / money coming to you.
  static const Color credit = Color(0xFF16A34A);

  static const Color creditLight = Color(0xFFDCFCE7);

  /// You owe someone money.
  /// Debit / money going out.
  static const Color debit = Color(0xFFDC2626);

  static const Color debitLight = Color(0xFFFEE2E2);

  /// Transaction or account needs attention.
  static const Color warning = Color(0xFFD97706);

  static const Color warningLight = Color(0xFFFEF3C7);

  /// Neutral / settled state.
  static const Color neutral = Color(0xFF64748B);

  static const Color neutralLight = Color(0xFFF1F5F9);

  // ============================================================
  // Status
  // ============================================================

  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // ============================================================
  // Light Theme
  // ============================================================

  static const Color lightBackground = Color(0xFFF8FAFC);

  static const Color lightSurface = Colors.white;

  static const Color lightTextPrimary = Color(0xFF0F172A);

  static const Color lightTextSecondary = Color(0xFF64748B);

  static const Color lightBorder = Color(0xFFE2E8F0);

  // ============================================================
  // Dark Theme
  // ============================================================

  static const Color darkBackground = Color(0xFF0F172A);

  static const Color darkSurface = Color(0xFF1E293B);

  static const Color darkSurfaceVariant = Color(0xFF334155);

  static const Color darkTextPrimary = Color(0xFFF8FAFC);

  static const Color darkTextSecondary = Color(0xFF94A3B8);

  static const Color darkBorder = Color(0xFF334155);

  // ============================================================
  // Common
  // ============================================================

  static const Color white = Colors.white;

  static const Color black = Colors.black;

  static const Color transparent = Colors.transparent;
}

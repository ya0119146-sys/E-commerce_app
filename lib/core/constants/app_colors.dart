import 'package:flutter/material.dart';

/// Labella Design System — Color Palette
/// Supports Light and Dark modes as per the UI/UX report.
class AppColors {
  AppColors._();

  // ─── Light Mode ───
  static const Color lightBackground = Color(0xFFFCF9F2); // Cream
  static const Color lightForeground = Color(0xFF2E2E2E);
  static const Color lightPrimary = Color(0xFFE5A1BA); // Rose
  static const Color lightSecondary = Color(0xFF7A405D); // Plum
  static const Color lightAccent = Color(0xFFD4A373); // Gold
  static const Color lightMuted = Color(0xFFF5EBE0);
  static const Color lightCard = Color(0xFFFBF7F0);
  static const Color lightBorder = Color(0xFFF2D5E0);

  // ─── Dark Mode ───
  static const Color darkBackground = Color(0xFF1D1418); // Deep Plum
  static const Color darkForeground = Color(0xFFFDFBF8);
  static const Color darkPrimary = Color(0xFFE5A1BA); // Rose
  static const Color darkSecondary = Color(0xFFA36684);
  static const Color darkAccent = Color(0xFFD4A373); // Gold
  static const Color darkMuted = Color(0xFF3A2A32);
  static const Color darkCard = Color(0xFF2D2026);
  static const Color darkBorder = Color(0xFF3F323A);

  // ─── Shared ───
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color error = Color(0xFFE74C3C);
  static const Color success = Color(0xFF2ECC71);

  // ─── Convenience helper ───
  static Color background(Brightness brightness) =>
      brightness == Brightness.light ? lightBackground : darkBackground;
  static Color foreground(Brightness brightness) =>
      brightness == Brightness.light ? lightForeground : darkForeground;
  static Color primary(Brightness brightness) =>
      brightness == Brightness.light ? lightPrimary : darkPrimary;
  static Color secondary(Brightness brightness) =>
      brightness == Brightness.light ? lightSecondary : darkSecondary;
  static Color accent(Brightness brightness) =>
      brightness == Brightness.light ? lightAccent : darkAccent;
  static Color muted(Brightness brightness) =>
      brightness == Brightness.light ? lightMuted : darkMuted;
  static Color card(Brightness brightness) =>
      brightness == Brightness.light ? lightCard : darkCard;
  static Color border(Brightness brightness) =>
      brightness == Brightness.light ? lightBorder : darkBorder;
}

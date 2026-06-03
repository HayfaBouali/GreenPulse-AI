// lib/app_theme.dart
// Thème GreenPulse AI : Palette oasis — vert profond + sable + alertes rouge

import 'package:flutter/material.dart';

class AppTheme {
  // Empêche l'instanciation
  AppTheme._();

  // ── Palette Verte GreenPulse ───────────────────────────────────────────────
  static const Color primaryGreen   = Color(0xFF1A6B3C);
  static const Color lightGreen     = Color(0xFF2E9E5B);
  static const Color accentGold     = Color(0xFFD4A843);
  static const Color sandBeige      = Color(0xFFF5E6C8);
  static const Color alertRed       = Color(0xFFD32F2F);
  static const Color warningOrange  = Color(0xFFE65100);
  static const Color backgroundDark = Color(0xFF0D1F15);
  static const Color surfaceDark    = Color(0xFF1A2E1F);
  static const Color cardDark       = Color(0xFF243B2A);

  // ── Thème sombre ──────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: accentGold,
        surface: surfaceDark,
        error: alertRed,
        background: backgroundDark, // Ajouté
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 4,
        margin: EdgeInsets.zero, // Ajouté pour éviter les marges par défaut
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 2, // Ajouté
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: accentGold,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        elevation: 8, // Réduit de 16 à 8
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
      ),
    );
  }

  // ── Styles texte ──────────────────────────────────────────────────────────
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28, 
    fontWeight: FontWeight.w800, 
    color: Colors.white, 
    height: 1.2,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22, 
    fontWeight: FontWeight.w700, 
    color: Colors.white,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16, 
    fontWeight: FontWeight.w600, 
    color: Colors.white,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14, 
    color: Colors.white70, 
    height: 1.5,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12, 
    color: Colors.white54, 
    letterSpacing: 0.8,
  );

  // ── Dégradés ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, lightGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient alertGradient = LinearGradient(
    colors: [alertRed, Color(0xFFB71C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient statusGradient(String urgency) {
    switch (urgency.toUpperCase()) { // Ajout de toUpperCase() pour robustesse
      case 'CRITICAL': 
        return const LinearGradient(
          colors: [alertRed, Color(0xFF7F0000)],
        );
      case 'HIGH':     
        return const LinearGradient(
          colors: [warningOrange, Color(0xFFBF360C)],
        );
      case 'MEDIUM':   
        return const LinearGradient(
          colors: [Color(0xFFF9A825), Color(0xFFE65100)],
        );
      default:         
        return const LinearGradient(
          colors: [primaryGreen, lightGreen],
        );
    }
  }

  static Color statusColor(String urgency) {
    switch (urgency.toUpperCase()) { // Ajout de toUpperCase()
      case 'CRITICAL': return alertRed;
      case 'HIGH':     return warningOrange;
      case 'MEDIUM':   return const Color(0xFFF9A825);
      default:         return primaryGreen;
    }
  }
}
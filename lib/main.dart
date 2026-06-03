// lib/main.dart
// ============================================================
// GreenPulse AI — Point d'entrée Flutter
// Navigation : Dashboard | Scanner | Carte
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/maps_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuration de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Verrouillage de l'orientation en portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const GreenPulseApp());
  });
}

class GreenPulseApp extends StatelessWidget {
  const GreenPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenPulse AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigation(),
      // Ajout de routes nommées (optionnel mais recommandé)
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/scanner': (context) => const ScannerScreen(),
        '/maps': (context) => const MapsScreen(),
      },
    );
  }
}

// ── Navigation principale ────────────────────────────────────────────────────
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Liste des écrans
  static const List<Widget> _screens = [
    DashboardScreen(),
    ScannerScreen(),
    MapsScreen(),
  ];

  // Items de la barre de navigation
  List<BottomNavigationBarItem> get _navItems => const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
          tooltip: 'Tableau de bord',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.document_scanner_outlined),
          activeIcon: Icon(Icons.document_scanner),
          label: 'Scanner',
          tooltip: 'Scanner un produit',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Carte',
          tooltip: 'Carte des points de collecte',
        ),
      ];

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppTheme.primaryGreen.withOpacity(0.2),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          items: _navItems,
          backgroundColor: AppTheme.surfaceDark,
          selectedItemColor: AppTheme.accentGold,
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}
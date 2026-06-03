// lib/screens/maps_screen.dart
// ============================================================
// GreenPulse AI — Carte GPS : 5 palmiers de l'oasis de Gabès
// Vert = Sain | Orange = Maladie Bio | Rouge = Alerte Chimique
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../app_theme.dart';
import '../models/palm_marker.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  GoogleMapController? _mapController;
  PalmMarker?          _selectedPalm;
  final Set<Marker>    _markers = {};

  // Centre de l'oasis de Gabès
  static const LatLng _oasisCenter = LatLng(33.8891, 10.1050);

  // Style sombre pour la carte
  static const String _darkMapStyle = '''
  [
    {"elementType":"geometry","stylers":[{"color":"#0d1f15"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#746855"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#17263c"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#1a2e1f"}]},
    {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#243b2a"}]}
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _buildMarkers();
  }

  /// Construit les marqueurs Google Maps.
  /// Couleur du marqueur selon le statut du palmier.
  Future<void> _buildMarkers() async {
    final Set<Marker> markers = {};

    for (final palm in oasisPalmiers) {
      final icon = await BitmapDescriptor.defaultMarkerWithHue(palm.markerHue);

      markers.add(
        Marker(
          markerId: MarkerId(palm.id),
          position: palm.position,
          icon: icon,
          infoWindow: InfoWindow(
            title: palm.name,
            snippet: palm.statusLabel,
          ),
          onTap: () => setState(() => _selectedPalm = palm),
        ),
      );
    }

    setState(() => _markers.addAll(markers));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('🗺️ Carte des Palmiers'),
        backgroundColor: AppTheme.backgroundDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppTheme.accentGold),
            onPressed: _centerOnOasis,
            tooltip: 'Centrer sur l\'oasis',
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Google Maps ──────────────────────────────────────────────────
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              controller.setMapStyle(_darkMapStyle);
            },
            initialCameraPosition: const CameraPosition(
              target: _oasisCenter,
              zoom: 13.5,
            ),
            markers: _markers,
            onTap: (_) => setState(() => _selectedPalm = null),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.hybrid,  // Vue satellite — plus impressionnant pour la démo
          ),

          // ── Légende ──────────────────────────────────────────────────────
          Positioned(
            top: 16, left: 16,
            child: _buildLegend(),
          ),

          // ── Compteur ─────────────────────────────────────────────────────
          Positioned(
            top: 16, right: 16,
            child: _buildStats(),
          ),

          // ── Info palmier sélectionné ─────────────────────────────────────
          if (_selectedPalm != null)
            Positioned(
              bottom: 20, left: 16, right: 16,
              child: _buildPalmInfoCard(_selectedPalm!),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LÉGENDE',
            style: TextStyle(
              color: AppTheme.accentGold, fontSize: 10,
              fontWeight: FontWeight.w700, letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          _LegendItem(color: Colors.green,           label: 'Sain'),
          const SizedBox(height: 4),
          _LegendItem(color: AppTheme.warningOrange, label: 'Maladie Bio'),
          const SizedBox(height: 4),
          _LegendItem(color: AppTheme.alertRed,      label: 'Alerte Chimique'),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final healthy = oasisPalmiers.where((p) => p.status == PalmStatus.healthy).length;
    final alerts  = oasisPalmiers.where((p) => p.status == PalmStatus.chemicalAlert).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '${oasisPalmiers.length}',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const Text(
            'Palmiers\nsuivis',
            style: TextStyle(color: Colors.white54, fontSize: 10),
            textAlign: TextAlign.center,
          ),
          const Divider(color: Colors.white12, height: 16),
          Text('✅ $healthy', style: const TextStyle(color: Colors.green, fontSize: 12)),
          Text('🚨 $alerts', style: const TextStyle(color: AppTheme.alertRed, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPalmInfoCard(PalmMarker palm) {
    final color = palm.status == PalmStatus.healthy
        ? AppTheme.primaryGreen
        : palm.status == PalmStatus.chemicalAlert
            ? AppTheme.alertRed
            : AppTheme.warningOrange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  palm.name,
                  style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white38, size: 18),
                onPressed: () => setState(() => _selectedPalm = null),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _InfoChip(label: 'Statut', value: palm.statusLabel, color: color)),
              const SizedBox(width: 8),
              Expanded(child: _InfoChip(label: 'ID', value: palm.id, color: Colors.white38)),
            ],
          ),
          if (palm.lastDiagnostic != null) ...[
            const SizedBox(height: 8),
            _InfoChip(label: 'Dernier diagnostic', value: palm.lastDiagnostic!, color: color),
          ],
          const SizedBox(height: 8),
          Text(
            '📍 GPS : ${palm.position.latitude.toStringAsFixed(4)}°N, '
            '${palm.position.longitude.toStringAsFixed(4)}°E',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  void _centerOnOasis() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(target: _oasisCenter, zoom: 13.5),
      ),
    );
  }
}

// ── Widgets locaux ────────────────────────────────────────────────────────────
class _LegendItem extends StatelessWidget {
  final Color  color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;
  const _InfoChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

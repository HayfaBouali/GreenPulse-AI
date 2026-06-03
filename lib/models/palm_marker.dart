// lib/models/palm_marker.dart
// ============================================================
// Données GPS des 5 palmiers de l'oasis de Gabès — GreenPulse AI
// ============================================================

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

/// Statut sanitaire d'un palmier
enum PalmStatus {
  healthy,
  bioDisease,
  chemicalAlert,
  unknown,
}

/// Extension pour faciliter l'utilisation de PalmStatus
extension PalmStatusExtension on PalmStatus {
  /// Retourne le label localisé du statut
  String get label {
    switch (this) {
      case PalmStatus.healthy:
        return 'Sain ✅';
      case PalmStatus.bioDisease:
        return 'Maladie Bio 🟡';
      case PalmStatus.chemicalAlert:
        return 'Alerte Chimique 🚨';
      case PalmStatus.unknown:
        return 'Non scanné ⬜';
    }
  }

  /// Retourne la couleur associée au statut
  Color get color {
    switch (this) {
      case PalmStatus.healthy:
        return const Color(0xFF2E9E5B); // AppTheme.lightGreen
      case PalmStatus.bioDisease:
        return const Color(0xFFE65100); // AppTheme.warningOrange
      case PalmStatus.chemicalAlert:
        return const Color(0xFFD32F2F); // AppTheme.alertRed
      case PalmStatus.unknown:
        return Colors.grey;
    }
  }

  /// Retourne la teinte pour le marqueur Google Maps
  double get markerHue {
    switch (this) {
      case PalmStatus.healthy:
        return BitmapDescriptor.hueGreen;
      case PalmStatus.bioDisease:
        return BitmapDescriptor.hueOrange;
      case PalmStatus.chemicalAlert:
        return BitmapDescriptor.hueRed;
      case PalmStatus.unknown:
        return BitmapDescriptor.hueAzure;
    }
  }
}

/// Modèle représentant un palmier géolocalisé dans l'oasis
class PalmMarker {
  final String id;
  final String name;
  final LatLng position;
  final PalmStatus status;
  final String? lastDiagnostic;
  final DateTime? lastScanDate;

  const PalmMarker({
    required this.id,
    required this.name,
    required this.position,
    required this.status,
    this.lastDiagnostic,
    this.lastScanDate,
  });

  /// Label du statut (délégué à l'extension)
  String get statusLabel => status.label;

  /// Couleur du statut
  Color get statusColor => status.color;

  /// Teinte du marqueur Google Maps
  double get markerHue => status.markerHue;

  /// Indique si le palmier a été scanné récemment (< 7 jours)
  bool get isRecentlyScan {
    if (lastScanDate == null) return false;
    final diff = DateTime.now().difference(lastScanDate!);
    return diff.inDays <= 7;
  }

  /// Indique si le palmier nécessite une attention
  bool get needsAttention =>
      status == PalmStatus.chemicalAlert || status == PalmStatus.bioDisease;

  /// Crée une copie avec certains champs modifiés
  PalmMarker copyWith({
    String? id,
    String? name,
    LatLng? position,
    PalmStatus? status,
    String? lastDiagnostic,
    DateTime? lastScanDate,
  }) {
    return PalmMarker(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      status: status ?? this.status,
      lastDiagnostic: lastDiagnostic ?? this.lastDiagnostic,
      lastScanDate: lastScanDate ?? this.lastScanDate,
    );
  }

  /// Convertit en JSON (pour stockage local ou API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'status': status.name,
      'lastDiagnostic': lastDiagnostic,
      'lastScanDate': lastScanDate?.toIso8601String(),
    };
  }

  /// Crée une instance depuis JSON
  factory PalmMarker.fromJson(Map<String, dynamic> json) {
    return PalmMarker(
      id: json['id'] as String,
      name: json['name'] as String,
      position: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      status: PalmStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PalmStatus.unknown,
      ),
      lastDiagnostic: json['lastDiagnostic'] as String?,
      lastScanDate: json['lastScanDate'] != null
          ? DateTime.parse(json['lastScanDate'] as String)
          : null,
    );
  }

  @override
  String toString() => 'PalmMarker($id, $name, $statusLabel)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PalmMarker && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ══════════════════════════════════════════════════════════════════════════════
// DONNÉES MOCK — 5 palmiers de l'oasis de Gabès
// ══════════════════════════════════════════════════════════════════════════════

/// Liste des palmiers surveillés dans l'oasis de Gabès
/// Coordonnées GPS réelles approximatives
final List<PalmMarker> oasisPalmiers = [
  PalmMarker(
    id: 'PALM_001',
    name: 'Palmier Nord — Zone A',
    position: const LatLng(33.9012, 10.1085),
    status: PalmStatus.healthy,
    lastDiagnostic: 'Healthy (94.2%)',
    lastScanDate: DateTime.now().subtract(const Duration(days: 1)),
  ),
  PalmMarker(
    id: 'PALM_002',
    name: 'Palmier Wadi Gabès — Zone B',
    position: const LatLng(33.8891, 10.0978),
    status: PalmStatus.chemicalAlert,
    lastDiagnostic: 'Chemical_Damage (88.7%)',
    lastScanDate: DateTime.now().subtract(const Duration(hours: 12)),
  ),
  PalmMarker(
    id: 'PALM_003',
    name: 'Palmier Centre — Zone C',
    position: const LatLng(33.8845, 10.1134),
    status: PalmStatus.healthy,
    lastDiagnostic: 'Healthy (91.3%)',
    lastScanDate: DateTime.now().subtract(const Duration(hours: 6)),
  ),
  PalmMarker(
    id: 'PALM_004',
    name: 'Palmier Sud-Est — Zone D',
    position: const LatLng(33.8756, 10.1289),
    status: PalmStatus.chemicalAlert,
    lastDiagnostic: 'Chemical_Damage (76.4%)',
    lastScanDate: DateTime.now().subtract(const Duration(days: 2)),
  ),
  PalmMarker(
    id: 'PALM_005',
    name: 'Palmier Oasis Chatt — Zone E',
    position: const LatLng(33.9134, 10.0756),
    status: PalmStatus.bioDisease,
    lastDiagnostic: 'Bio_Disease (82.1%)',
    lastScanDate: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

// ── Getters utilitaires ───────────────────────────────────────────────────────

/// Retourne les palmiers nécessitant une attention
List<PalmMarker> get palmersNeedingAttention =>
    oasisPalmiers.where((p) => p.needsAttention).toList();

/// Retourne les palmiers sains
List<PalmMarker> get healthyPalmers =>
    oasisPalmiers.where((p) => p.status == PalmStatus.healthy).toList();

/// Retourne les palmiers avec alerte chimique
List<PalmMarker> get chemicalAlertPalmers => oasisPalmiers
    .where((p) => p.status == PalmStatus.chemicalAlert)
    .toList();

/// Retourne les palmiers avec maladie biologique
List<PalmMarker> get bioDiseasePalmers =>
    oasisPalmiers.where((p) => p.status == PalmStatus.bioDisease).toList();

/// Trouve un palmier par son ID
PalmMarker? findPalmerById(String id) {
  try {
    return oasisPalmiers.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}
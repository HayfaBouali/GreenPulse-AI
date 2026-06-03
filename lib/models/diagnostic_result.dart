// lib/models/diagnostic_result.dart
// Modèle de données pour le résultat du diagnostic CNN — GreenPulse AI

class DiagnosticResult {
  final String? palmId;
  final String predictedClass;
  final double confidence;
  final Map<String, double> scores;
  final String recommendation;
  final String urgencyLevel;
  final DateTime timestamp;

  DiagnosticResult({
    this.palmId,
    required this.predictedClass,
    required this.confidence,
    required this.scores,
    required this.recommendation,
    required this.urgencyLevel,
    required this.timestamp,
  });

  factory DiagnosticResult.fromJson(Map<String, dynamic> json) {
    return DiagnosticResult(
      palmId: json['palm_id'],
      predictedClass: json['predicted_class'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      scores: Map<String, double>.from(
        (json['scores'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
      ),
      recommendation: json['recommendation'] ?? '',
      urgencyLevel: json['urgency_level'] ?? 'LOW',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isHealthy  => predictedClass == 'Healthy';
  bool get isChemical => predictedClass == 'Chemical_Damage';
  bool get isBio      => predictedClass == 'Bio_Disease';

  String get urgencyEmoji {
    switch (urgencyLevel) {
      case 'CRITICAL': return '🚨';
      case 'HIGH':     return '⚠️';
      case 'MEDIUM':   return '🟡';
      default:         return '✅';
    }
  }

  String get classLabel {
    switch (predictedClass) {
      case 'Healthy':         return 'Sain';
      case 'Bio_Disease':     return 'Maladie Biologique';
      case 'Chemical_Damage': return 'Dommage Chimique';
      default:                return predictedClass;
    }
  }
}

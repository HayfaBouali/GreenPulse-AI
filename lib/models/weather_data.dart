// lib/models/weather_data.dart
// Modèle météo + pollution pour Gabès — GreenPulse AI

class WeatherData {
  final String location;
  final double temperatureC;
  final double humidityPercent;
  final double windSpeedKmh;
  final double so2Ugm3;
  final double pm25Ugm3;
  final double phosphateIndex;
  final String airQualityLabel;
  final String? alert;
  final DateTime timestamp;

  WeatherData({
    required this.location,
    required this.temperatureC,
    required this.humidityPercent,
    required this.windSpeedKmh,
    required this.so2Ugm3,
    required this.pm25Ugm3,
    required this.phosphateIndex,
    required this.airQualityLabel,
    this.alert,
    required this.timestamp,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location:        json['location'] ?? 'Gabès, Tunisie',
      temperatureC:    (json['temperature_c'] ?? 28.0).toDouble(),
      humidityPercent: (json['humidity_percent'] ?? 60.0).toDouble(),
      windSpeedKmh:    (json['wind_speed_kmh'] ?? 18.0).toDouble(),
      so2Ugm3:         (json['so2_ugm3'] ?? 87.0).toDouble(),
      pm25Ugm3:        (json['pm25_ugm3'] ?? 45.0).toDouble(),
      phosphateIndex:  (json['phosphate_index'] ?? 3.7).toDouble(),
      airQualityLabel: json['air_quality_label'] ?? 'Modérée',
      alert:           json['alert'],
      timestamp:       DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  bool get so2AboveWHO => so2Ugm3 > 20.0;
  bool get isCritical  => so2Ugm3 > 100.0;

  factory WeatherData.mock() {
    return WeatherData(
      location:        'Gabès, Tunisie',
      temperatureC:    29.3,
      humidityPercent: 64.0,
      windSpeedKmh:    21.5,
      so2Ugm3:         92.7,
      pm25Ugm3:        48.3,
      phosphateIndex:  3.8,
      airQualityLabel: 'Dégradée',
      alert: '⚠️ Pollution chimique élevée. Surveillance renforcée recommandée.',
      timestamp: DateTime.now(),
    );
  }
}

class PollutionHistory {
  final List<String> labels;
  final List<double> so2Values;
  final List<double> pm25Values;
  final double whoThreshold;

  PollutionHistory({
    required this.labels,
    required this.so2Values,
    required this.pm25Values,
    required this.whoThreshold,
  });

  factory PollutionHistory.fromJson(Map<String, dynamic> json) {
    return PollutionHistory(
      labels:       List<String>.from(json['labels'] ?? []),
      so2Values:    List<double>.from(
        (json['so2_values'] as List? ?? []).map((v) => (v as num).toDouble()),
      ),
      pm25Values:   List<double>.from(
        (json['pm25_values'] as List? ?? []).map((v) => (v as num).toDouble()),
      ),
      whoThreshold: (json['who_threshold'] ?? 20.0).toDouble(),
    );
  }

  factory PollutionHistory.mock() {
    return PollutionHistory(
      labels:       ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
      so2Values:    [72.0, 85.0, 91.0, 68.0, 110.0, 95.0, 87.0],
      pm25Values:   [32.0, 38.0, 41.0, 31.0, 49.0, 43.0, 39.0],
      whoThreshold: 20.0,
    );
  }
}

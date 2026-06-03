// lib/services/api_service.dart
// Service HTTP centralisé — GreenPulse AI

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';   // ← ajoute kDebugMode
import 'package:http/http.dart' as http;
import '../models/diagnostic_result.dart';
import '../models/weather_data.dart';
import 'dart:async';

class ApiService {
  // Android émulateur : 10.0.2.2  |  Appareil réel : IP WiFi de ton PC
  static const String _baseUrl = 'http://10.218.231.77:8000';
  // static const String _baseUrl = 'http://192.168.1.X:8000';

  static const Duration _timeout = Duration(seconds: 30);

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ── Diagnostic CNN ──────────────────────────────────────────────────────
  static Future<DiagnosticResult> predictImage({
    required File imageFile,
    String? palmId,
  }) async {
    try {
      final bytes       = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final body = jsonEncode({
        'image_base64': base64Image,
        'palm_id': palmId,
      });

      final response = await http
          .post(
            Uri.parse('$_baseUrl/predict'),
            headers: _headers,
            body: body,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return DiagnosticResult.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw ApiException('Erreur serveur ${response.statusCode}', response.statusCode);
      }
    } on SocketException {
      throw ApiException(
        'Impossible de joindre le serveur. Vérifiez que FastAPI tourne.', 503);
    } on TimeoutException {
      throw ApiException('Timeout — le serveur met trop de temps à répondre.', 408);
    }
  }

  // ── Météo ───────────────────────────────────────────────────────────────
  static Future<WeatherData> getWeather() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/weather'), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return WeatherData.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return WeatherData.mock();
    } catch (e) {
      if (kDebugMode) print('Erreur météo: $e');
      return WeatherData.mock();
    }
  }

  // ── Historique pollution ────────────────────────────────────────────────
  static Future<PollutionHistory> getPollutionHistory() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/pollution/history'), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return PollutionHistory.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      }
      return PollutionHistory.mock();
    } catch (e) {
      if (kDebugMode) print('Erreur pollution history: $e');
      return PollutionHistory.mock();
    }
  }

  // ── Health check ────────────────────────────────────────────────────────
  static Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

// ── Exception personnalisée ──────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

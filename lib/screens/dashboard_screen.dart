// lib/screens/dashboard_screen.dart
// ============================================================
// GreenPulse AI — Dashboard : Météo + Graphique pollution fl_chart
// ============================================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../models/weather_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  WeatherData?      _weather;
  PollutionHistory? _history;
  bool              _isLoading = true;

  late AnimationController _fadeController;
  late Animation<double>   _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final weather = await ApiService.getWeather();
    final history = await ApiService.getPollutionHistory();
    setState(() {
      _weather   = weather;
      _history   = history;
      _isLoading = false;
    });
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primaryGreen,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── AppBar ────────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              backgroundColor: AppTheme.backgroundDark,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.backgroundDark, AppTheme.surfaceDark],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primaryGreen.withOpacity(0.5),
                                  ),
                                ),
                                child: const Text('🌿', style: TextStyle(fontSize: 24)),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'GreenPulse AI',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Oasis de Gabès — Surveillance en temps réel',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.accentGold.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Corps ─────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_isLoading) ...[
                    const SizedBox(height: 40),
                    const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Chargement des données...',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ] else
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_weather?.alert != null) _buildAlertBanner(),
                          const SizedBox(height: 16),

                          _sectionTitle('CONDITIONS ACTUELLES'),
                          const SizedBox(height: 10),
                          _buildWeatherGrid(),
                          const SizedBox(height: 24),

                          _sectionTitle('ÉVOLUTION POLLUTION SO₂ — 7 JOURS'),
                          const SizedBox(height: 10),
                          _buildPollutionChart(),
                          const SizedBox(height: 24),

                          _buildPalmStats(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppTheme.accentGold,
      letterSpacing: 1.5,
    ),
  );

  // ── Bannière alerte ───────────────────────────────────────────────────────
  Widget _buildAlertBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppTheme.alertGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.alertRed.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🚨', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _weather!.alert!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Grille météo ──────────────────────────────────────────────────────────
  Widget _buildWeatherGrid() {
    if (_weather == null) return const SizedBox.shrink();
    final w = _weather!;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _MeteoCard(icon: '🌡️', label: 'Température',    value: '${w.temperatureC}°C',   color: AppTheme.accentGold),
        _MeteoCard(icon: '💧', label: 'Humidité',       value: '${w.humidityPercent}%', color: Colors.lightBlue),
        _MeteoCard(
          icon: '☁️', label: 'SO₂',
          value: '${w.so2Ugm3} µg/m³',
          color: w.so2AboveWHO ? AppTheme.alertRed : AppTheme.primaryGreen,
          subtitle: w.so2AboveWHO ? '⚠️ > Seuil OMS' : '✅ Normal',
        ),
        _MeteoCard(
          icon: '🏭', label: 'Index Phosphate',
          value: '${w.phosphateIndex}',
          color: AppTheme.warningOrange,
          subtitle: 'Source: SIAPE/GCT',
        ),
      ],
    );
  }

  // ── Graphique SO₂ (fl_chart) ──────────────────────────────────────────────
  Widget _buildPollutionChart() {
    if (_history == null) return const SizedBox.shrink();
    final h = _history!;

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: LineChart(
        LineChartData(
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: h.whoThreshold,
                color: AppTheme.alertRed.withOpacity(0.7),
                strokeWidth: 1.5,
                dashArray: [5, 5],
                label: HorizontalLineLabel(
                  show: true,
                  labelResolver: (_) => 'Seuil OMS',
                  style: const TextStyle(color: AppTheme.alertRed, fontSize: 10),
                  alignment: Alignment.topRight,
                ),
              ),
            ],
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (_) => FlLine(color: Colors.white10, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 30,
                reservedSize: 40,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= h.labels.length) return const SizedBox.shrink();
                  return Text(
                    h.labels[idx],
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // Courbe SO₂
            LineChartBarData(
              spots: h.so2Values.asMap().entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              color: AppTheme.alertRed,
              barWidth: 2.5,
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.alertRed.withOpacity(0.1),
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.alertRed,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
            ),
            // Courbe PM2.5
            LineChartBarData(
              spots: h.pm25Values.asMap().entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              color: AppTheme.warningOrange,
              barWidth: 2,
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.warningOrange.withOpacity(0.08),
              ),
              dotData: const FlDotData(show: false),
            ),
          ],
          minY: 0,
          maxY: 130,
        ),
      ),
    );
  }

  // ── Stats palmiers ────────────────────────────────────────────────────────
  Widget _buildPalmStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🌴 ÉTAT DE L\'OASIS — 5 ZONES SURVEILLÉES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.accentGold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatPill(count: 2, label: 'Sains',          color: AppTheme.primaryGreen),
              _StatPill(count: 1, label: 'Maladie Bio',     color: AppTheme.warningOrange),
              _StatPill(count: 2, label: 'Alerte Chimique', color: AppTheme.alertRed),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Widgets locaux ────────────────────────────────────────────────────────────
class _MeteoCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color  color;
  final String? subtitle;

  const _MeteoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          if (subtitle != null)
            Text(subtitle!, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final int    count;
  final String label;
  final Color  color;
  const _StatPill({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
            border: Border.all(color: color, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            '$count',
            style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

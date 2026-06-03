// lib/screens/scanner_screen.dart
// GreenPulse AI — Scanner : Caméra + Animation Scan + BottomSheet Résultat

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../models/diagnostic_result.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with TickerProviderStateMixin {
  File?             _selectedImage;
  bool              _isAnalyzing = false;
  DiagnosticResult? _lastResult;

  late AnimationController _scanController;
  late Animation<double>   _scanAnimation;
  late AnimationController _pulseController;
  late Animation<double>   _pulseAnimation;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (xFile == null) return;
      setState(() {
        _selectedImage = File(xFile.path);
        _lastResult    = null;
      });
    } catch (e) {
      _showSnackBar('Erreur caméra : $e', isError: true);
    }
  }

  Future<void> _analyze() async {
    if (_selectedImage == null) return;

    setState(() => _isAnalyzing = true);
    _scanController.repeat(reverse: true);

    try {
      final result = await ApiService.predictImage(
        imageFile: _selectedImage!,
        palmId: 'PALM_SCAN_${DateTime.now().millisecondsSinceEpoch}',
      );
      setState(() {
        _lastResult  = result;
        _isAnalyzing = false;
      });
      _scanController.stop();
      _scanController.reset();
      if (mounted) _showResultBottomSheet(result);
    } on ApiException catch (e) {
      setState(() => _isAnalyzing = false);
      _scanController.stop();
      _showSnackBar('Erreur API : ${e.message}', isError: true);
    } catch (e) {
      setState(() => _isAnalyzing = false);
      _scanController.stop();
      _showSnackBar('Erreur inattendue : $e', isError: true);
    }
  }

  void _showResultBottomSheet(DiagnosticResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DiagnosticBottomSheet(result: result),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.alertRed : AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('🔬 Scanner une Feuille'),
        backgroundColor: AppTheme.backgroundDark,
        actions: [
          if (_lastResult != null)
            TextButton(
              onPressed: () => _showResultBottomSheet(_lastResult!),
              child: const Text('Résultat',
                  style: TextStyle(color: AppTheme.accentGold)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildScanArea(),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildActionButtons(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Zone de scan ────────────────────────────────────────────────────────
  Widget _buildScanArea() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (_, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isAnalyzing
                  ? AppTheme.alertRed.withOpacity(_pulseAnimation.value)
                  : AppTheme.primaryGreen.withOpacity(0.4),
              width: 2,
            ),
            color: AppTheme.surfaceDark,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _selectedImage == null
                  ? _buildPlaceholder()
                  : Image.file(_selectedImage!, fit: BoxFit.cover),

              if (_isAnalyzing)
                Container(color: AppTheme.backgroundDark.withOpacity(0.4)),

              // Ligne de scan animée
              if (_isAnalyzing)
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (_, __) {
                    return Positioned(
                      top: _scanAnimation.value *
                          (MediaQuery.of(context).size.height * 0.35),
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppTheme.primaryGreen,
                              AppTheme.accentGold,
                              AppTheme.primaryGreen,
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGreen.withOpacity(0.6),
                              blurRadius: 12,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              // Badge "Analyse en cours"
              if (_isAnalyzing)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundDark.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.primaryGreen.withOpacity(0.5)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Analyse CNN en cours...',
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Coins de scanner
              ..._buildScanCorners(),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildScanCorners() {
    const size = 24.0;
    final color = _isAnalyzing ? AppTheme.accentGold : AppTheme.primaryGreen;

    Widget corner({
      bool flipH = false,
      bool flipV = false,
      double? top,
      double? bottom,
      double? left,
      double? right,
    }) {
      return Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: Transform.flip(
          flipX: flipH,
          flipY: flipV,
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(painter: _CornerPainter(color: color)),
          ),
        ),
      );
    }

    return [
      corner(top: 12, left: 12),
      corner(top: 12, right: 12, flipH: true),
      corner(bottom: 12, left: 12, flipV: true),
      corner(bottom: 12, right: 12, flipH: true, flipV: true),
    ];
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt_outlined,
            size: 64, color: AppTheme.primaryGreen.withOpacity(0.5)),
        const SizedBox(height: 16),
        const Text(
          'Prenez une photo\nd\'une feuille de palmier',
          style: TextStyle(color: Colors.white54, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'GreenPulse AI analysera la santé\nde la plante en quelques secondes',
          style: TextStyle(color: Colors.white38, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Boutons ──────────────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    _isAnalyzing ? null : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galerie'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    _isAnalyzing ? null : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Caméra'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                (_selectedImage == null || _isAnalyzing) ? null : _analyze,
            icon: _isAnalyzing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.biotech_outlined),
            label:
                Text(_isAnalyzing ? 'Analyse en cours...' : '🧠 Analyser avec l\'IA'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedImage == null
                  ? Colors.white12
                  : AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── BottomSheet Résultat ──────────────────────────────────────────────────────
class _DiagnosticBottomSheet extends StatelessWidget {
  final DiagnosticResult result;
  const _DiagnosticBottomSheet({required this.result});

  @override
  Widget build(BuildContext context) {
    final urgencyColor = AppTheme.statusColor(result.urgencyLevel);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: urgencyColor.withOpacity(0.4)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Résultat principal ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.statusGradient(result.urgencyLevel),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(result.urgencyEmoji,
                      style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    result.classLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Confiance : ${result.confidence.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,  // ← corrigé : white au lieu de white87
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: result.confidence / 100,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Scores 3 classes ────────────────────────────────────────
            const Text(
              'PROBABILITÉS PAR CLASSE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.accentGold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            ...result.scores.entries
                .map((e) => _ScoreBar(
                      label: _classLabel(e.key),
                      value: e.value,
                      color: _classColor(e.key),
                    ))
                ,
            const SizedBox(height: 20),

            // ── Recommandation ──────────────────────────────────────────
            const Text(
              'RECOMMANDATION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.accentGold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: urgencyColor.withOpacity(0.3)),
              ),
              child: Text(
                result.recommendation,
                style: const TextStyle(
                  color: Colors.white,   // ← corrigé : white au lieu de white87
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Fermer',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  String _classLabel(String key) {
    switch (key) {
      case 'Healthy':         return '✅ Sain';
      case 'Bio_Disease':     return '🟡 Maladie Bio';
      case 'Chemical_Damage': return '🚨 Dommage Chimique';
      default:                return key;
    }
  }

  Color _classColor(String key) {
    switch (key) {
      case 'Healthy':         return AppTheme.primaryGreen;
      case 'Bio_Disease':     return AppTheme.warningOrange;
      case 'Chemical_Damage': return AppTheme.alertRed;
      default:                return Colors.white38;
    }
  }
}

// ── Score bar ──────────────────────────────────────────────────────────────
class _ScoreBar extends StatelessWidget {
  final String label;
  final double value;
  final Color  color;
  const _ScoreBar(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              Text(
                '${value.toStringAsFixed(1)}%',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Corner painter ──────────────────────────────────────────────────────────
class _CornerPainter extends CustomPainter {
  final Color color;
  const _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => color != old.color;
}

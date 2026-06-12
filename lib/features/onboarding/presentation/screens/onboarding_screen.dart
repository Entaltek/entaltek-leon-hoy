import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/app_preferences.dart';
import '../../../../core/theme/app_theme.dart';

class _OnboardingData {
  const _OnboardingData({
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    required this.accentColor,
    required this.icon,
    required this.painter,
  });

  final String title;
  final String subtitle;
  final Color primaryColor;
  final Color accentColor;
  final IconData icon;
  final CustomPainter painter;
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _illustrationController;

  late final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'Gasolineras en tiempo real',
      subtitle:
          'Consulta precios actualizados de las 180 estaciones de servicio '
          'de León directamente desde la API gubernamental CNE.',
      primaryColor: AppColors.primary,
      accentColor: AppColors.accent,
      icon: Icons.local_gas_station,
      painter: _GasDropPainter(color: AppColors.primary),
    ),
    _OnboardingData(
      title: 'Ahorra en cada carga',
      subtitle:
          'Compara precios de gasolina regular, premium y diésel. '
          'Encuentra la opción más económica cerca de ti.',
      primaryColor: AppColors.buttonOutline,
      accentColor: AppColors.accent,
      icon: Icons.savings,
      painter: _MapPinsPainter(color: AppColors.buttonOutline),
    ),
    _OnboardingData(
      title: 'Tus favoritas a un toque',
      subtitle:
          'Guarda las gasolineras que más usas. Accede a sus precios '
          'al instante, sin buscar en el mapa.',
      primaryColor: AppColors.darkBackground,
      accentColor: AppColors.primary,
      icon: Icons.favorite,
      painter: _HeartPainter(color: AppColors.primary),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _illustrationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _illustrationController.dispose();
    super.dispose();
  }

  Future<void> _markAndNavigate() async {
    await ref.read(appPreferencesProvider).markOnboardingSeen();
    if (mounted) context.go('/login');
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _markAndNavigate();
    }
  }

  void _skip() => _markAndNavigate();

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      body: Stack(
        children: [
          // Fondo animado que transiciona de color entre páginas.
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  page.primaryColor,
                  page.primaryColor.withOpacity(0.7),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Botón Skip arriba a la derecha.
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _skip,
                    child: const Text(
                      'Omitir',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, index) =>
                        _OnboardingPage(data: _pages[index]),
                  ),
                ),
                // Indicadores y botón de acción.
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                  child: Column(
                    children: [
                      _PageIndicator(
                        count: _pages.length,
                        currentIndex: _currentPage,
                        activeColor: page.accentColor,
                      ),
                      const SizedBox(height: 32),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: page.primaryColor,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          onPressed: _next,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              _currentPage == _pages.length - 1
                                  ? '¡Comenzar!'
                                  : 'Siguiente',
                              key: ValueKey(_currentPage),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ilustración con CustomPainter + bounce animation.
          SizedBox(
            width: 220,
            height: 220,
            child: CustomPaint(painter: data.painter)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 0.95,
                  end: 1.0,
                  duration: 2400.ms,
                  curve: Curves.easeInOut,
                ),
          ),
          const SizedBox(height: 40),
          Text(
            data.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 500.ms)
              .slideY(
                begin: 0.2,
                end: 0,
                delay: 150.ms,
                duration: 500.ms,
              ),
        ],
      ),
    );
  }
}

/// Indicador de página con píldora deslizante.
class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.count,
    required this.currentIndex,
    required this.activeColor,
  });

  final int count;
  final int currentIndex;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.white30,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ── Ilustraciones con CustomPainter ──────────────────────────────────────────

class _GasDropPainter extends CustomPainter {
  _GasDropPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()..color = color.withOpacity(0.2);
    final paintStrong = Paint()..color = color;

    // Ondas de fondo.
    for (int i = 3; i >= 1; i--) {
      canvas.drawCircle(
        Offset(cx, cy),
        (size.width / 2) * (i / 3),
        paint,
      );
    }

    // Gota central.
    final path = Path();
    final r = size.width * 0.18;
    path.moveTo(cx, cy - r * 2.2);
    path.cubicTo(
      cx + r * 1.5, cy - r * 0.5,
      cx + r * 1.5, cy + r,
      cx, cy + r * 1.5,
    );
    path.cubicTo(
      cx - r * 1.5, cy + r,
      cx - r * 1.5, cy - r * 0.5,
      cx, cy - r * 2.2,
    );
    canvas.drawPath(path, paintStrong);

    // Brillo dentro de la gota.
    canvas.drawCircle(
      Offset(cx - r * 0.4, cy - r * 0.6),
      r * 0.3,
      Paint()..color = Colors.white.withOpacity(0.4),
    );
  }

  @override
  bool shouldRepaint(_GasDropPainter old) => false;
}

class _MapPinsPainter extends CustomPainter {
  _MapPinsPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Cuadrícula de puntos simulando un mapa.
    final dotPaint = Paint()..color = color.withOpacity(0.15);
    for (double x = 20; x < size.width; x += 28) {
      for (double y = 20; y < size.height; y += 28) {
        canvas.drawCircle(Offset(x, y), 2, dotPaint);
      }
    }

    // Pin principal grande.
    _drawPin(canvas, Offset(cx, cy - 10), size.width * 0.16, color, true);
    // Pines secundarios.
    _drawPin(
      canvas, Offset(cx - 55, cy + 20), size.width * 0.09,
      color.withOpacity(0.5), false,
    );
    _drawPin(
      canvas, Offset(cx + 50, cy + 30), size.width * 0.09,
      color.withOpacity(0.5), false,
    );
  }

  void _drawPin(
    Canvas canvas, Offset center, double r, Color c, bool withDollar,
  ) {
    final paint = Paint()..color = c;
    // Cuerpo del pin.
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: r))
      ..moveTo(center.dx, center.dy + r)
      ..lineTo(center.dx - r * 0.4, center.dy + r * 2.2)
      ..lineTo(center.dx + r * 0.4, center.dy + r * 2.2)
      ..close();
    canvas.drawPath(path, paint);
    // Círculo interior blanco.
    canvas.drawCircle(center, r * 0.55, Paint()..color = Colors.white);
    if (withDollar) {
      // Símbolo $ en el centro.
      final tp = TextPainter(
        text: TextSpan(
          text: '\$',
          style: TextStyle(
            color: c,
            fontSize: r * 0.9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_MapPinsPainter old) => false;
}

class _HeartPainter extends CustomPainter {
  _HeartPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Corazón escalado.
    final paint = Paint()..color = color;
    final s = size.width * 0.32;
    final path = _heartPath(Offset(cx, cy + s * 0.15), s);
    canvas.drawPath(path, paint);

    // Destellos alrededor.
    final sparklePaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * math.pi;
      final r1 = s * 1.6;
      final r2 = s * 1.95;
      canvas.drawLine(
        Offset(cx + r1 * math.cos(angle), cy + r1 * math.sin(angle)),
        Offset(cx + r2 * math.cos(angle), cy + r2 * math.sin(angle)),
        sparklePaint,
      );
    }
  }

  Path _heartPath(Offset center, double size) {
    final path = Path();
    final x = center.dx;
    final y = center.dy;
    path.moveTo(x, y + size * 0.35);
    path.cubicTo(x, y, x - size, y, x - size, y - size * 0.4);
    path.cubicTo(
      x - size, y - size, x, y - size * 0.8, x, y - size * 0.35,
    );
    path.cubicTo(
      x, y - size * 0.8, x + size, y - size, x + size, y - size * 0.4,
    );
    path.cubicTo(x + size, y, x, y, x, y + size * 0.35);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_HeartPainter old) => false;
}

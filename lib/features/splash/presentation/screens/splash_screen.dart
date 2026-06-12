import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/app_preferences.dart';
import '../../../../core/storage/secure_storage_impl.dart';
import '../../../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ringsController;

  @override
  void initState() {
    super.initState();
    _ringsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _navigate();
  }

  Future<void> _navigate() async {
    // Espera mínima para que la animación sea visible.
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    final prefs = ref.read(appPreferencesProvider);
    final hasSeenOnboarding = await prefs.hasSeenOnboarding();

    if (!mounted) return;

    if (!hasSeenOnboarding) {
      context.go('/onboarding');
      return;
    }

    final token = await ref.read(secureStorageProvider).getAccessToken();
    if (!mounted) return;
    context.go(token != null ? '/home/map' : '/login');
  }

  @override
  void dispose() {
    _ringsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Anillos expansivos animados con CustomPainter.
          AnimatedBuilder(
            animation: _ringsController,
            builder: (context, _) => CustomPaint(
              painter: _RingsPainter(progress: _ringsController.value),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_gas_station,
                    color: Colors.white,
                    size: 48,
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      delay: 200.ms,
                      duration: 700.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: 24),
                const Text(
                  'León Hoy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      delay: 600.ms,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: 8),
                const Text(
                  'por Entaltek',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 3,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 600.ms)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      delay: 900.ms,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ],
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white12,
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).animate().fadeIn(delay: 1200.ms, duration: 400.ms),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius =
        math.sqrt(size.width * size.width + size.height * size.height);

    const ringCount = 4;
    for (int i = 0; i < ringCount; i++) {
      final phase = i / ringCount;
      final t = ((progress - phase) % 1.0).clamp(0.0, 1.0);
      final radius = t * maxRadius * 0.9;
      final opacity = (1.0 - t) * 0.15;
      if (opacity <= 0) continue;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = AppColors.accent.withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.progress != progress;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Gauge semicircular animado para mostrar un precio de combustible.
/// El arco se colorea de verde (barato) a rojo (caro) según el rango.
class FuelPriceGauge extends StatefulWidget {
  const FuelPriceGauge({
    super.key,
    required this.label,
    required this.price,
    required this.minPrice,
    required this.maxPrice,
  });

  final String label;
  final double price;
  final double minPrice;
  final double maxPrice;

  @override
  State<FuelPriceGauge> createState() => _FuelPriceGaugeState();
}

class _FuelPriceGaugeState extends State<FuelPriceGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;

  double get _normalizedValue {
    final range = widget.maxPrice - widget.minPrice;
    if (range == 0) return 0.5;
    return ((widget.price - widget.minPrice) / range).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnim = Tween<double>(begin: 0, end: _normalizedValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(FuelPriceGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.price != widget.price) {
      _progressAnim = Tween<double>(
        begin: _progressAnim.value,
        end: _normalizedValue,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 100,
          height: 60,
          child: AnimatedBuilder(
            animation: _progressAnim,
            builder: (context, _) => CustomPaint(
              painter: _GaugePainter(progress: _progressAnim.value),
            ),
          ),
        ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: _progressAnim,
          builder: (context, _) {
            final displayPrice =
                widget.minPrice + _progressAnim.value * (widget.maxPrice - widget.minPrice);
            return Text(
              '\$${displayPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.darkBackground,
              ),
            );
          },
        ),
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;
    final radius = size.width * 0.46;

    final trackPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // Track de fondo.
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      math.pi,
      math.pi,
      false,
      trackPaint,
    );

    // Gradiente del arco activo (verde → amarillo → rojo).
    final sweepAngle = math.pi * progress;
    if (sweepAngle > 0.01) {
      final color = Color.lerp(
        const Color(0xFF4CAF50),
        const Color(0xFFF44336),
        progress,
      )!;

      final arcPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        math.pi,
        sweepAngle,
        false,
        arcPaint,
      );

      // Punto indicador.
      final angle = math.pi + sweepAngle;
      final dotX = cx + radius * math.cos(angle);
      final dotY = cy + radius * math.sin(angle);
      canvas.drawCircle(
        Offset(dotX, dotY),
        7,
        Paint()..color = color,
      );
      canvas.drawCircle(
        Offset(dotX, dotY),
        4,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.progress != progress;
}

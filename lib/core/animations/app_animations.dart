import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Duraciones canónicas para mantener consistencia visual en toda la app.
abstract final class AppDurations {
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 600);
  static const xslow = Duration(milliseconds: 900);
}

abstract final class AppCurves {
  static const spring = Curves.easeOutBack;
  static const smooth = Curves.easeInOutCubic;
  static const decelerate = Curves.easeOutCubic;
  static const accelerate = Curves.easeInCubic;
}

/// Widget que envuelve [child] con fade + slide vertical de entrada.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.beginY = 24.0,
    this.duration = AppDurations.slow,
  });

  final Widget child;
  final Duration delay;
  final double beginY;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration, curve: AppCurves.smooth)
        .slideY(
          begin: beginY / 100,
          end: 0,
          duration: duration,
          curve: AppCurves.decelerate,
        );
  }
}

/// Lista cuyos ítems aparecen en cascada con delay incremental.
class StaggeredList extends StatelessWidget {
  const StaggeredList({
    super.key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 80),
    this.initialDelay = Duration.zero,
  });

  final List<Widget> children;
  final Duration itemDelay;
  final Duration initialDelay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < children.length; i++)
          FadeSlideIn(
            delay: initialDelay + (itemDelay * i),
            child: children[i],
          ),
      ],
    );
  }
}

/// Efecto de pulso que escala ligeramente el widget de forma continua.
class PulseWidget extends StatelessWidget {
  const PulseWidget({super.key, required this.child, this.scale = 1.06});

  final Widget child;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: Offset(scale, scale),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
        );
  }
}

/// Shimmer de ancho/alto fijo para placeholders de carga.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

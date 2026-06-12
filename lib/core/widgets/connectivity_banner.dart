import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_banner.g.dart';

@riverpod
Stream<bool> isOffline(IsOfflineRef ref) {
  return Connectivity().onConnectivityChanged.map(
        (results) => results.every((r) => r == ConnectivityResult.none),
      );
}

/// Banner deslizante que aparece cuando no hay conexión a internet.
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineAsync = ref.watch(isOfflineProvider);

    final isOffline = offlineAsync.maybeWhen(
      data: (v) => v,
      orElse: () => false,
    );

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          height: isOffline ? 40 : 0,
          color: Colors.red.shade700,
          child: isOffline
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Sin conexión — mostrando datos en caché',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 200))
              : const SizedBox.shrink(),
        ),
        Expanded(child: child),
      ],
    );
  }
}

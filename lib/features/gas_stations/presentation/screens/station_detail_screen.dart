import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../favorites/presentation/providers/favorites_notifier.dart';
import '../../../favorites/presentation/state/favorites_state.dart';
import '../../domain/entities/gas_station.dart';
import '../providers/stations_notifier.dart';
import '../state/stations_ui_state.dart';
import '../widgets/fuel_price_gauge.dart';

class StationDetailScreen extends ConsumerWidget {
  const StationDetailScreen({super.key, required this.station});

  final GasStation station;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favState = ref.watch(favoritesNotifierProvider);
    final isFav = favState is FavoritesLoaded && favState.contains(station.id);

    // Para los gauges necesitamos el rango de precios del dataset completo.
    final stationsState = ref.watch(stationsNotifierProvider);
    final (minR, maxR, minP, maxP, minD, maxD) = switch (stationsState) {
      StationsSuccess(:final stations) => _priceRanges(stations),
      _ => (18.0, 28.0, 20.0, 30.0, 19.0, 27.0),
    };

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con mapa de fondo (placeholder azul con pin animado).
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: 300.ms,
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_outline,
                    key: ValueKey(isFav),
                    color: isFav ? Colors.red.shade300 : Colors.white,
                  ),
                ),
                onPressed: () => ref
                    .read(favoritesNotifierProvider.notifier)
                    .toggle(station.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                station.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: _MapPlaceholder(station: station),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Marca y dirección.
                  _InfoRow(
                    icon: Icons.business,
                    label: station.brand,
                    delay: 0.ms,
                  ),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: station.address,
                    delay: 80.ms,
                  ),
                  _InfoRow(
                    icon: Icons.update,
                    label:
                        'Actualizado: ${_formatDate(station.lastUpdated)}',
                    delay: 160.ms,
                  ),
                  const SizedBox(height: 28),

                  // Título gauges.
                  const Text(
                    'Precios por litro',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBackground,
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: 8),
                  const Text(
                    'El gauge muestra qué tan caro es este precio '
                    'comparado con todas las estaciones de León.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ).animate(delay: 240.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: 24),

                  // Tres gauges animados en fila.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      FuelPriceGauge(
                        label: 'Regular',
                        price: station.regularPrice,
                        minPrice: minR,
                        maxPrice: maxR,
                      ),
                      FuelPriceGauge(
                        label: 'Premium',
                        price: station.premiumPrice,
                        minPrice: minP,
                        maxPrice: maxP,
                      ),
                      FuelPriceGauge(
                        label: 'Diésel',
                        price: station.dieselPrice,
                        minPrice: minD,
                        maxPrice: maxD,
                      ),
                    ],
                  ).animate(delay: 300.ms).fadeIn(duration: 500.ms).slideY(
                        begin: 0.15,
                        end: 0,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 32),

                  // Comparativa visual de precios.
                  _PriceComparisonCard(station: station)
                      .animate(delay: 500.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  (double, double, double, double, double, double) _priceRanges(
    List<GasStation> stations,
  ) {
    if (stations.isEmpty) return (18, 28, 20, 30, 19, 27);
    double minR = double.infinity, maxR = 0;
    double minP = double.infinity, maxP = 0;
    double minD = double.infinity, maxD = 0;
    for (final s in stations) {
      if (s.regularPrice < minR) minR = s.regularPrice;
      if (s.regularPrice > maxR) maxR = s.regularPrice;
      if (s.premiumPrice < minP) minP = s.premiumPrice;
      if (s.premiumPrice > maxP) maxP = s.premiumPrice;
      if (s.dieselPrice < minD) minD = s.dieselPrice;
      if (s.dieselPrice > maxD) maxD = s.dieselPrice;
    }
    return (minR, maxR, minP, maxP, minD, maxD);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.delay,
  });

  final IconData icon;
  final String label;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ).animate(delay: delay).fadeIn(duration: 350.ms).slideX(
            begin: -0.05,
            end: 0,
            duration: 350.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}

/// Fondo del SliverAppBar: mapa simple con pin pulsante.
class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.station});

  final GasStation station;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.darkBackground],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, color: Colors.white, size: 48)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.1, 1.1),
                  duration: 900.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 4),
            Text(
              '${station.latitude.toStringAsFixed(4)}, '
              '${station.longitude.toStringAsFixed(4)}',
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card con barras de progreso comparando los tres combustibles.
class _PriceComparisonCard extends StatelessWidget {
  const _PriceComparisonCard({required this.station});

  final GasStation station;

  @override
  Widget build(BuildContext context) {
    final maxVal = [
      station.regularPrice,
      station.premiumPrice,
      station.dieselPrice,
    ].reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comparativa de combustibles',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 16),
          _ProgressBar(
            label: 'Regular',
            price: station.regularPrice,
            maxPrice: maxVal,
            color: const Color(0xFF4CAF50),
          ),
          _ProgressBar(
            label: 'Premium',
            price: station.premiumPrice,
            maxPrice: maxVal,
            color: AppColors.primary,
          ),
          _ProgressBar(
            label: 'Diésel',
            price: station.dieselPrice,
            maxPrice: maxVal,
            color: const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.label,
    required this.price,
    required this.maxPrice,
    required this.color,
  });

  final String label;
  final double price;
  final double maxPrice;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: maxPrice > 0 ? price / maxPrice : 0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 52,
            child: Text(
              '\$${price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

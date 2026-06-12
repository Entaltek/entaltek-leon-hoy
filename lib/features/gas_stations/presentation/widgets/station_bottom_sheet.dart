import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../favorites/presentation/providers/favorites_notifier.dart';
import '../../../favorites/presentation/state/favorites_state.dart';
import '../../domain/entities/gas_station.dart';
import '../screens/station_detail_screen.dart';

class StationBottomSheet extends ConsumerWidget {
  const StationBottomSheet({super.key, required this.station});

  final GasStation station;

  static void show(BuildContext context, GasStation station) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
      builder: (_) => StationBottomSheet(station: station),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favState = ref.watch(favoritesNotifierProvider);
    final isFav =
        favState is FavoritesLoaded && favState.contains(station.id);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle.
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera nombre + favorito.
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            station.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ).animate().fadeIn(duration: 300.ms).slideY(
                                begin: 0.2,
                                end: 0,
                                duration: 300.ms,
                              ),
                          Text(
                            station.brand,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ).animate(delay: 60.ms).fadeIn(duration: 300.ms),
                        ],
                      ),
                    ),
                    // Botón favorito.
                    IconButton(
                      icon: AnimatedSwitcher(
                        duration: 300.ms,
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_outline,
                          key: ValueKey(isFav),
                          color: isFav ? Colors.red : Colors.grey,
                          size: 28,
                        ),
                      ),
                      onPressed: () => ref
                          .read(favoritesNotifierProvider.notifier)
                          .toggle(station.id),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Dirección.
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        station.address,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ),
                  ],
                ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
                const SizedBox(height: 16),

                // Precios.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _PriceColumn(
                      label: 'Regular',
                      price: station.regularPrice,
                      color: const Color(0xFF4CAF50),
                    ),
                    _PriceColumn(
                      label: 'Premium',
                      price: station.premiumPrice,
                      color: AppColors.primary,
                    ),
                    _PriceColumn(
                      label: 'Diésel',
                      price: station.dieselPrice,
                      color: const Color(0xFFFF9800),
                    ),
                  ],
                ).animate(delay: 140.ms).fadeIn(duration: 400.ms).slideY(
                      begin: 0.1,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: 20),

                // Botón "Ver detalles" con OpenContainer para Container Transform.
                SizedBox(
                  width: double.infinity,
                  child: OpenContainer<void>(
                    transitionDuration: const Duration(milliseconds: 450),
                    transitionType: ContainerTransitionType.fadeThrough,
                    openColor: theme.colorScheme.surface,
                    closedColor: AppColors.primary,
                    closedElevation: 0,
                    closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    openBuilder: (context, _) =>
                        StationDetailScreen(station: station),
                    closedBuilder: (context, openContainer) => InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        openContainer();
                      },
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: const Text(
                          'Ver detalles',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate(delay: 240.ms).fadeIn(duration: 400.ms).slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Actualizado: ${_formatDate(station.lastUpdated)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ).animate(delay: 280.ms).fadeIn(duration: 300.ms),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}

class _PriceColumn extends StatelessWidget {
  const _PriceColumn({
    required this.label,
    required this.price,
    required this.color,
  });

  final String label;
  final double price;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: price),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              '\$${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

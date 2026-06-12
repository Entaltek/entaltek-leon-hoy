import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/gas_station.dart';
import '../screens/station_detail_screen.dart';

/// Tarjeta animada de gasolinera con transición OpenContainer (Material Motion).
class StationCard extends ConsumerStatefulWidget {
  const StationCard({
    super.key,
    required this.station,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final GasStation station;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  ConsumerState<StationCard> createState() => _StationCardState();
}

class _StationCardState extends ConsumerState<StationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _onFavoriteTap() {
    // Animación de bounce en el corazón.
    _heartController.forward(from: 0);
    widget.onFavoriteTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = widget.station;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OpenContainer<void>(
        transitionDuration: const Duration(milliseconds: 450),
        transitionType: ContainerTransitionType.fadeThrough,
        openColor: theme.colorScheme.surface,
        closedColor: theme.colorScheme.surface,
        closedElevation: 2,
        openElevation: 0,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        openBuilder: (context, _) => StationDetailScreen(station: s),
        closedBuilder: (context, openContainer) => InkWell(
          onTap: openContainer,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Ícono de marca con fondo de color.
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_gas_station,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            s.brand,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón favorito con animación de corazón.
                    AnimatedBuilder(
                      animation: _heartController,
                      builder: (context, child) {
                        final scale = _heartController.value < 0.5
                            ? 1.0 + _heartController.value * 0.6
                            : 1.3 - (_heartController.value - 0.5) * 0.6;
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Icon(
                            widget.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            key: ValueKey(widget.isFavorite),
                            color: widget.isFavorite
                                ? Colors.red
                                : Colors.grey,
                            size: 22,
                          ),
                        ),
                        onPressed: _onFavoriteTap,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Chips de precio por tipo de combustible.
                Row(
                  children: [
                    _PriceChip(
                      label: 'Regular',
                      price: s.regularPrice,
                      color: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 8),
                    _PriceChip(
                      label: 'Premium',
                      price: s.premiumPrice,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    _PriceChip(
                      label: 'Diésel',
                      price: s.dieselPrice,
                      color: const Color(0xFFFF9800),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        s.address,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({
    required this.label,
    required this.price,
    required this.color,
  });

  final String label;
  final double price;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    )
        .animate()
        .shimmer(
          duration: const Duration(milliseconds: 1200),
          color: color.withOpacity(0.1),
          delay: const Duration(milliseconds: 500),
        );
  }
}

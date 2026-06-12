import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../favorites/presentation/providers/favorites_notifier.dart';
import '../../../favorites/presentation/state/favorites_state.dart';
import '../../domain/entities/gas_station.dart';
import '../providers/stations_notifier.dart';
import '../state/stations_ui_state.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/station_card.dart';

class StationsListScreen extends ConsumerStatefulWidget {
  const StationsListScreen({super.key});

  @override
  ConsumerState<StationsListScreen> createState() =>
      _StationsListScreenState();
}

class _StationsListScreenState extends ConsumerState<StationsListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stationsState = ref.watch(stationsNotifierProvider);
    final favState = ref.watch(favoritesNotifierProvider);
    final filter = ref.watch(filterNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gasolineras'),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o marca…',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Botón de filtros con badge indicador.
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.tune),
                      onPressed: () => showFilterSheet(context),
                    ),
                    // Badge si hay filtros activos.
                    if (!filter.sortByPrice ||
                        filter.onlyOpen ||
                        filter.maxPrice < 30)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: switch (stationsState) {
        StationsLoading() || StationsInitial() => const _ShimmerList(),
        StationsError(:final message) => _ErrorView(
            message: message,
            onRetry: () =>
                ref.read(stationsNotifierProvider.notifier).refresh(),
          ),
        StationsSuccess(:final stations) => _StationsList(
            stations: _applyFilters(stations, filter),
            favState: favState,
          ),
      },
    );
  }

  List<GasStation> _applyFilters(
    List<GasStation> stations,
    FilterState filter,
  ) {
    var result = stations.where((s) {
      final q = _query.toLowerCase();
      if (q.isNotEmpty &&
          !s.name.toLowerCase().contains(q) &&
          !s.brand.toLowerCase().contains(q)) {
        return false;
      }
      final price = switch (filter.fuelType) {
        FuelType.regular => s.regularPrice,
        FuelType.premium => s.premiumPrice,
        FuelType.diesel => s.dieselPrice,
      };
      if (price > filter.maxPrice) return false;
      return true;
    }).toList();

    if (filter.sortByPrice) {
      result.sort((a, b) {
        final pa = switch (filter.fuelType) {
          FuelType.regular => a.regularPrice,
          FuelType.premium => a.premiumPrice,
          FuelType.diesel => a.dieselPrice,
        };
        final pb = switch (filter.fuelType) {
          FuelType.regular => b.regularPrice,
          FuelType.premium => b.premiumPrice,
          FuelType.diesel => b.dieselPrice,
        };
        return pa.compareTo(pb);
      });
    }
    return result;
  }
}

class _StationsList extends ConsumerWidget {
  const _StationsList({required this.stations, required this.favState});

  final List<GasStation> stations;
  final FavoritesState favState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (stations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Sin resultados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  ref.read(filterNotifierProvider.notifier).reset(),
              child: const Text('Limpiar filtros'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: stations.length,
      itemBuilder: (context, i) {
        final s = stations[i];
        final isFav =
            favState is FavoritesLoaded && (favState as FavoritesLoaded).contains(s.id);
        return StationCard(
          station: s,
          isFavorite: isFav,
          onFavoriteTap: () =>
              ref.read(favoritesNotifierProvider.notifier).toggle(s.id),
        ).animate(delay: (60 * i).ms).fadeIn(duration: 350.ms).slideY(
              begin: 0.05,
              end: 0,
              duration: 350.ms,
              curve: Curves.easeOutCubic,
            );
      },
    );
  }
}

/// Shimmer placeholder durante la carga inicial.
class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: 6,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

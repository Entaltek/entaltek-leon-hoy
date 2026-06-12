import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../favorites/presentation/providers/favorites_notifier.dart';
import '../../../favorites/presentation/state/favorites_state.dart';
import '../../domain/entities/gas_station.dart';
import '../providers/stations_notifier.dart';
import '../state/stations_ui_state.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/station_bottom_sheet.dart';

const _leonCenter = LatLng(21.1236, -101.6860);

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  String? _selectedStationId;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onMarkerTap(GasStation station) {
    setState(() => _selectedStationId = station.id);
    StationBottomSheet.show(context, station);
  }

  Set<Marker> _buildMarkers(
    List<GasStation> stations,
    FavoritesState favState,
  ) {
    final filter = ref.read(filterNotifierProvider);
    return stations.map((station) {
      final isSelected = station.id == _selectedStationId;
      final isFav =
          favState is FavoritesLoaded && favState.contains(station.id);

      // Color del marcador según tipo de combustible seleccionado y precio.
      final price = switch (filter.fuelType) {
        FuelType.regular => station.regularPrice,
        FuelType.premium => station.premiumPrice,
        FuelType.diesel => station.dieselPrice,
      };

      final hue = price < 22
          ? BitmapDescriptor.hueGreen
          : price < 24
              ? BitmapDescriptor.hueYellow
              : BitmapDescriptor.hueRed;

      return Marker(
        markerId: MarkerId(station.id),
        position: LatLng(station.latitude, station.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isFav
              ? BitmapDescriptor.hueAzure
              : isSelected
                  ? BitmapDescriptor.hueViolet
                  : hue,
        ),
        infoWindow: InfoWindow(
          title: station.name,
          snippet: '\$${station.regularPrice.toStringAsFixed(2)} regular',
        ),
        onTap: () => _onMarkerTap(station),
        zIndex: isSelected ? 2 : (isFav ? 1 : 0),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final stationsState = ref.watch(stationsNotifierProvider);
    final favState = ref.watch(favoritesNotifierProvider);
    final filter = ref.watch(filterNotifierProvider);
    final hasActiveFilter =
        !filter.sortByPrice || filter.onlyOpen || filter.maxPrice < 30;

    return Scaffold(
      body: Stack(
        children: [
          // Mapa.
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _leonCenter,
              zoom: 13,
            ),
            markers: stationsState is StationsSuccess
                ? _buildMarkers(stationsState.stations, favState)
                : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (c) => _mapController = c,
          ),

          // Overlay de carga/error.
          switch (stationsState) {
            StationsLoading() => const _LoadingOverlay(),
            StationsError(:final message) => _ErrorBanner(message: message),
            StationsInitial() || StationsSuccess() =>
              const SizedBox.shrink(),
          },

          // Barra de búsqueda superior + leyenda.
          SafeArea(
            child: Column(
              children: [
                // Card con estadísticas rápidas si hay estaciones cargadas.
                if (stationsState is StationsSuccess)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _StatsCard(stations: stationsState.stations)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: -0.3, end: 0, duration: 400.ms),
                  ),
              ],
            ),
          ),
        ],
      ),
      // FAB columna con múltiples acciones.
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // FAB refresh.
          FloatingActionButton.small(
            heroTag: 'refresh',
            onPressed: () =>
                ref.read(stationsNotifierProvider.notifier).refresh(),
            child: const Icon(Icons.refresh),
          )
              .animate(delay: 300.ms)
              .scale(curve: Curves.easeOutBack)
              .fadeIn(),
          const SizedBox(height: 8),
          // FAB centrar mapa.
          FloatingActionButton.small(
            heroTag: 'center',
            onPressed: () => _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(_leonCenter, 13),
            ),
            child: const Icon(Icons.my_location),
          )
              .animate(delay: 200.ms)
              .scale(curve: Curves.easeOutBack)
              .fadeIn(),
          const SizedBox(height: 8),
          // FAB principal: filtros (con badge si activos).
          Stack(
            clipBehavior: Clip.none,
            children: [
              FloatingActionButton.extended(
                heroTag: 'filter',
                onPressed: () => showFilterSheet(context),
                icon: const Icon(Icons.tune),
                label: const Text('Filtros'),
                backgroundColor: hasActiveFilter
                    ? AppColors.accent
                    : null,
                foregroundColor: hasActiveFilter
                    ? AppColors.darkBackground
                    : null,
              ),
              if (hasActiveFilter)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          )
              .animate(delay: 100.ms)
              .scale(curve: Curves.easeOutBack)
              .fadeIn(),
        ],
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ),
      ),
    );
  }
}

/// Card compacta con precio mínimo de regular en León.
class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stations});

  final List<GasStation> stations;

  @override
  Widget build(BuildContext context) {
    if (stations.isEmpty) return const SizedBox.shrink();

    final minRegular = stations
        .map((s) => s.regularPrice)
        .reduce((a, b) => a < b ? a : b);

    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_gas_station,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              '${stations.length} estaciones',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 1, height: 16, color: Colors.grey.shade300),
            const SizedBox(width: 12),
            const Text(
              'Mín. regular',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(width: 6),
            Text(
              '\$${minRegular.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

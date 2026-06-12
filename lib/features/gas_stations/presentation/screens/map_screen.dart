import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/gas_station.dart';
import '../providers/stations_notifier.dart';
import '../state/stations_ui_state.dart';
import '../widgets/station_bottom_sheet.dart';

const _leonCenter = LatLng(21.1236, -101.6860);

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stationsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('León Hoy — Gasolineras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(stationsNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Stack(
        children: [
          _MapView(state: state),
          switch (state) {
            StationsLoading() => const _LoadingOverlay(),
            StationsError(:final message) => _ErrorOverlay(message: message),
            StationsInitial() || StationsSuccess() => const SizedBox.shrink(),
          },
        ],
      ),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView({required this.state});

  final StationsUiState state;

  Set<Marker> _buildMarkers(
    BuildContext context,
    List<GasStation> stations,
  ) {
    return stations.map((station) {
      return Marker(
        markerId: MarkerId(station.id),
        position: LatLng(station.latitude, station.longitude),
        infoWindow: InfoWindow(title: station.name, snippet: station.brand),
        onTap: () => StationBottomSheet.show(context, station),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final markers = state is StationsSuccess
        ? _buildMarkers(context, (state as StationsSuccess).stations)
        : <Marker>{};

    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: _leonCenter,
        zoom: 13,
      ),
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
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

class _ErrorOverlay extends StatelessWidget {
  const _ErrorOverlay({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
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

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/usecases/get_stations_usecase.dart';
import '../../data/repositories/gas_station_repository_impl.dart';
import '../state/stations_ui_state.dart';

part 'stations_notifier.g.dart';

// keepAlive: true porque el mapa, la lista y favoritos comparten estas estaciones.
@Riverpod(keepAlive: true)
class StationsNotifier extends _$StationsNotifier {
  @override
  StationsUiState build() {
    _load();
    return const StationsLoading();
  }

  Future<void> _load() async {
    final useCase = GetStationsUseCase(ref.read(gasStationRepositoryProvider));
    final result = await useCase();

    state = result.fold(
      (failure) => StationsError(failure.toString()),
      StationsSuccess.new,
    );
  }

  Future<void> refresh() async {
    state = const StationsLoading();
    await _load();
  }
}

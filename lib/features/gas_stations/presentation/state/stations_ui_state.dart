import '../../domain/entities/gas_station.dart';

sealed class StationsUiState {
  const StationsUiState();
}

final class StationsInitial extends StationsUiState {
  const StationsInitial();
}

final class StationsLoading extends StationsUiState {
  const StationsLoading();
}

final class StationsSuccess extends StationsUiState {
  const StationsSuccess(this.stations);

  final List<GasStation> stations;
}

final class StationsError extends StationsUiState {
  const StationsError(this.message);

  final String message;
}

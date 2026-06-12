import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/gas_station.dart';
import '../repositories/gas_station_repository.dart';

class GetStationsUseCase {
  const GetStationsUseCase(this._repository);

  final GasStationRepository _repository;

  Future<Either<Failure, List<GasStation>>> call() =>
      _repository.getStations();
}

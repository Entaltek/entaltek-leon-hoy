import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/gas_station.dart';

abstract class GasStationRepository {
  Future<Either<Failure, List<GasStation>>> getStations();
}

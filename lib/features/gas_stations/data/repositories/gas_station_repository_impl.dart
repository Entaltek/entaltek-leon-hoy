import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/gas_station.dart';
import '../../domain/repositories/gas_station_repository.dart';
import '../datasources/stations_remote_datasource.dart';
import '../dtos/gas_station_dto.dart';

part 'gas_station_repository_impl.g.dart';

const _cacheBoxName = 'gas_stations_cache';
const _cacheKey = 'stations';

class GasStationRepositoryImpl implements GasStationRepository {
  const GasStationRepositoryImpl(this._dataSource);

  final StationsRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, List<GasStation>>> getStations() async {
    try {
      final dtos = await _dataSource.getStations();
      await _cacheStations(dtos);
      return Right(dtos.map((dto) => dto.toDomain()).toList());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        // Offline-first: intenta servir desde cache local.
        final cached = await _loadFromCache();
        if (cached != null) return Right(cached);
        return const Left(NetworkFailure());
      }
      final status = e.response?.statusCode ?? 0;
      if (status == 401) return const Left(UnauthorizedFailure());
      return Left(
        ServerFailure(e.response?.statusMessage ?? 'Error del servidor'),
      );
    } catch (_) {
      return const Left(ServerFailure('Error inesperado'));
    }
  }

  Future<void> _cacheStations(List<GasStationDto> dtos) async {
    final box = await Hive.openBox<String>(_cacheBoxName);
    // Serializa como JSON string para simplicidad; se puede migrar a TypeAdapter.
    await box.put(
      _cacheKey,
      dtos.map((d) => d.toJson().toString()).toList().toString(),
    );
  }

  Future<List<GasStation>?> _loadFromCache() async {
    try {
      final box = await Hive.openBox<String>(_cacheBoxName);
      // Cache hit pero sin deserializar (placeholder hasta agregar TypeAdapter).
      final raw = box.get(_cacheKey);
      if (raw == null) return null;
      // TODO(dev): implementar deserialización completa con TypeAdapter de Hive.
      return null;
    } catch (_) {
      return null;
    }
  }
}

@riverpod
GasStationRepository gasStationRepository(GasStationRepositoryRef ref) =>
    GasStationRepositoryImpl(ref.read(stationsRemoteDataSourceProvider));

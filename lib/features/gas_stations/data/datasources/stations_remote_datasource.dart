import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../dtos/gas_station_dto.dart';

part 'stations_remote_datasource.g.dart';

abstract class StationsRemoteDataSource {
  Future<List<GasStationDto>> getStations();
}

class StationsRemoteDataSourceImpl implements StationsRemoteDataSource {
  const StationsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<GasStationDto>> getStations() async {
    final response = await _dio.get<List<dynamic>>('/stations');
    return (response.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(GasStationDto.fromJson)
        .toList();
  }
}

@riverpod
StationsRemoteDataSource stationsRemoteDataSource(
  StationsRemoteDataSourceRef ref,
) =>
    StationsRemoteDataSourceImpl(ref.read(dioClientProvider));

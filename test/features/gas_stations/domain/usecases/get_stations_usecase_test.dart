import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:leon_hoy/core/error/failures.dart';
import 'package:leon_hoy/features/gas_stations/domain/entities/gas_station.dart';
import 'package:leon_hoy/features/gas_stations/domain/repositories/gas_station_repository.dart';
import 'package:leon_hoy/features/gas_stations/domain/usecases/get_stations_usecase.dart';

class MockGasStationRepository extends Mock implements GasStationRepository {}

void main() {
  late MockGasStationRepository mockRepository;
  late GetStationsUseCase useCase;

  final tStations = [
    GasStation(
      id: 'g1',
      name: 'PEMEX León Centro',
      brand: 'PEMEX',
      address: 'Blvd. López Mateos 1, León',
      latitude: 21.1236,
      longitude: -101.6860,
      regularPrice: 22.50,
      premiumPrice: 24.10,
      dieselPrice: 23.80,
      lastUpdated: DateTime(2024, 1, 1),
    ),
  ];

  setUp(() {
    mockRepository = MockGasStationRepository();
    useCase = GetStationsUseCase(mockRepository);
  });

  group('GetStationsUseCase', () {
    test('retorna lista de estaciones en caso de éxito', () async {
      when(() => mockRepository.getStations())
          .thenAnswer((_) async => Right(tStations));

      final result = await useCase();

      expect(result, Right<Failure, List<GasStation>>(tStations));
      verify(() => mockRepository.getStations()).called(1);
    });

    test('retorna NetworkFailure cuando no hay conexión', () async {
      when(() => mockRepository.getStations())
          .thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase();

      expect(result, const Left<Failure, List<GasStation>>(NetworkFailure()));
    });

    test('retorna ServerFailure en error del servidor', () async {
      when(() => mockRepository.getStations()).thenAnswer(
        (_) async => const Left(ServerFailure('Internal Server Error')),
      );

      final result = await useCase();

      expect(
        result,
        const Left<Failure, List<GasStation>>(
          ServerFailure('Internal Server Error'),
        ),
      );
    });
  });
}

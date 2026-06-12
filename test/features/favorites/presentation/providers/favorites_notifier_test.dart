import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:leon_hoy/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:leon_hoy/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:leon_hoy/features/favorites/presentation/providers/favorites_notifier.dart';
import 'package:leon_hoy/features/favorites/presentation/state/favorites_state.dart';

import '../../../../helpers/test_helpers.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  late MockFavoritesRepository mockRepo;

  setUp(() {
    mockRepo = MockFavoritesRepository();
  });

  group('FavoritesNotifier', () {
    test('build carga los IDs favoritos y emite FavoritesLoaded', () async {
      when(() => mockRepo.getFavoriteIds())
          .thenAnswer((_) async => {'station-1', 'station-2'});

      final container = createContainer(
        overrides: [
          favoritesRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      // Espera a que build() termine su carga asíncrona.
      await Future<void>.delayed(Duration.zero);

      final state = container.read(favoritesNotifierProvider);
      expect(state, isA<FavoritesLoaded>());
      expect((state as FavoritesLoaded).ids, {'station-1', 'station-2'});
    });

    test('isFavorite retorna true si el id está en el set', () async {
      when(() => mockRepo.getFavoriteIds())
          .thenAnswer((_) async => {'station-1'});

      final container = createContainer(
        overrides: [
          favoritesRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      await Future<void>.delayed(Duration.zero);

      final notifier = container.read(favoritesNotifierProvider.notifier);
      expect(notifier.isFavorite('station-1'), isTrue);
      expect(notifier.isFavorite('station-99'), isFalse);
    });

    test('toggle llama al repositorio y recarga el estado', () async {
      when(() => mockRepo.getFavoriteIds())
          .thenAnswer((_) async => <String>{});
      when(() => mockRepo.toggleFavorite('station-1'))
          .thenAnswer((_) async {});

      final container = createContainer(
        overrides: [
          favoritesRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      await Future<void>.delayed(Duration.zero);
      await container
          .read(favoritesNotifierProvider.notifier)
          .toggle('station-1');

      verify(() => mockRepo.toggleFavorite('station-1')).called(1);
    });

    test('emite FavoritesError si el repositorio lanza excepción', () async {
      when(() => mockRepo.getFavoriteIds())
          .thenThrow(Exception('Hive error'));

      final container = createContainer(
        overrides: [
          favoritesRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      await Future<void>.delayed(Duration.zero);

      final state = container.read(favoritesNotifierProvider);
      expect(state, isA<FavoritesError>());
    });
  });
}

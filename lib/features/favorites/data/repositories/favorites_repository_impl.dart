import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/favorites_repository.dart';

part 'favorites_repository_impl.g.dart';

const _boxName = 'favorites';

class FavoritesRepositoryImpl implements FavoritesRepository {
  @override
  Future<Set<String>> getFavoriteIds() async {
    final box = await Hive.openBox<String>(_boxName);
    return box.values.toSet();
  }

  @override
  Future<void> toggleFavorite(String stationId) async {
    final box = await Hive.openBox<String>(_boxName);
    if (box.containsKey(stationId)) {
      await box.delete(stationId);
    } else {
      await box.put(stationId, stationId);
    }
  }

  @override
  Future<bool> isFavorite(String stationId) async {
    final box = await Hive.openBox<String>(_boxName);
    return box.containsKey(stationId);
  }
}

@Riverpod(keepAlive: true)
FavoritesRepository favoritesRepository(FavoritesRepositoryRef ref) =>
    FavoritesRepositoryImpl();

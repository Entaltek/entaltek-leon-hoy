import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/favorites_repository_impl.dart';
import '../state/favorites_state.dart';

part 'favorites_notifier.g.dart';

@Riverpod(keepAlive: true)
class FavoritesNotifier extends _$FavoritesNotifier {
  @override
  FavoritesState build() {
    _load();
    return const FavoritesLoading();
  }

  Future<void> _load() async {
    try {
      final ids =
          await ref.read(favoritesRepositoryProvider).getFavoriteIds();
      state = FavoritesLoaded(ids);
    } catch (e) {
      state = FavoritesError(e.toString());
    }
  }

  Future<void> toggle(String stationId) async {
    await ref.read(favoritesRepositoryProvider).toggleFavorite(stationId);
    // Recarga para reflejar el nuevo estado.
    await _load();
  }

  bool isFavorite(String stationId) {
    final s = state;
    if (s is FavoritesLoaded) return s.contains(stationId);
    return false;
  }
}

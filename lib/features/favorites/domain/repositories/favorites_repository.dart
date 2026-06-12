abstract class FavoritesRepository {
  Future<Set<String>> getFavoriteIds();

  Future<void> toggleFavorite(String stationId);

  Future<bool> isFavorite(String stationId);
}

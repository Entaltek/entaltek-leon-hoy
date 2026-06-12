sealed class FavoritesState {
  const FavoritesState();
}

final class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

final class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded(this.ids);

  final Set<String> ids;

  bool contains(String id) => ids.contains(id);
}

final class FavoritesError extends FavoritesState {
  const FavoritesError(this.message);

  final String message;
}

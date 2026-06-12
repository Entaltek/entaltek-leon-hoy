import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../gas_stations/presentation/providers/stations_notifier.dart';
import '../../../gas_stations/presentation/state/stations_ui_state.dart';
import '../../../gas_stations/presentation/widgets/station_card.dart';
import '../providers/favorites_notifier.dart';
import '../state/favorites_state.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favState = ref.watch(favoritesNotifierProvider);
    final stationsState = ref.watch(stationsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis favoritas'),
        centerTitle: false,
      ),
      body: switch (favState) {
        FavoritesLoading() => const Center(child: CircularProgressIndicator()),
        FavoritesError(:final message) => _ErrorView(message: message),
        FavoritesLoaded(:final ids) => _FavoritesList(
            favoriteIds: ids,
            stationsState: stationsState,
          ),
      },
    );
  }
}

class _FavoritesList extends ConsumerWidget {
  const _FavoritesList({
    required this.favoriteIds,
    required this.stationsState,
  });

  final Set<String> favoriteIds;
  final StationsUiState stationsState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (favoriteIds.isEmpty) return const _EmptyFavorites();

    return switch (stationsState) {
      StationsLoading() || StationsInitial() => const Center(
          child: CircularProgressIndicator(),
        ),
      StationsError(:final message) => _ErrorView(message: message),
      StationsSuccess(:final stations) => () {
          final favorites =
              stations.where((s) => favoriteIds.contains(s.id)).toList();
          if (favorites.isEmpty) return const _EmptyFavorites();
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: favorites.length,
            itemBuilder: (context, i) => StationCard(
              station: favorites[i],
              isFavorite: true,
              onFavoriteTap: () =>
                  ref.read(favoritesNotifierProvider.notifier).toggle(
                        favorites[i].id,
                      ),
            )
                .animate(delay: (80 * i).ms)
                .fadeIn(duration: 400.ms)
                .slideX(begin: -0.05, end: 0, duration: 400.ms),
          );
        }(),
    };
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite_outline,
            size: 72,
            color: AppColors.accent,
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                duration: 1200.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 24),
          Text(
            'Sin favoritas aún',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Toca el ♡ en cualquier gasolinera\npara agregarla aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

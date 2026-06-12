import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'animated_bottom_nav_bar.dart';
import 'connectivity_banner.dart';

const _tabs = [
  NavItem(
    icon: Icons.map_outlined,
    activeIcon: Icons.map,
    label: 'Mapa',
  ),
  NavItem(
    icon: Icons.list_alt_outlined,
    activeIcon: Icons.list_alt,
    label: 'Lista',
  ),
  NavItem(
    icon: Icons.favorite_outline,
    activeIcon: Icons.favorite,
    label: 'Favoritos',
  ),
];

/// Scaffold principal de home con bottom nav animado y banner de conectividad.
///
/// Recibe [navigationShell] de [StatefulShellRoute.indexedStack] para que
/// GoRouter gestione el IndexedStack y preserve el estado de cada branch.
class HomeScaffold extends ConsumerWidget {
  const HomeScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ConnectivityBanner(
        // navigationShell es el IndexedStack gestionado por GoRouter.
        child: navigationShell,
      ),
      bottomNavigationBar: AnimatedBottomNavBar(
        items: _tabs,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          // initialLocation: true restaura la ubicación inicial del branch
          // cuando el usuario vuelve a un tab ya visitado.
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

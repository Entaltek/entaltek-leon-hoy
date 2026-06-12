import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/gas_stations/presentation/screens/map_screen.dart';
import '../../features/gas_stations/presentation/screens/stations_list_screen.dart';
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

class HomeScaffold extends ConsumerStatefulWidget {
  const HomeScaffold({super.key, required this.tab});

  final int tab;

  @override
  ConsumerState<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends ConsumerState<HomeScaffold> {
  late int _currentTab;

  static const _screens = [
    MapScreen(),
    StationsListScreen(),
    FavoritesScreen(),
  ];

  static const _routes = ['/home/map', '/home/list', '/home/favorites'];

  @override
  void initState() {
    super.initState();
    _currentTab = widget.tab;
  }

  @override
  void didUpdateWidget(HomeScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tab != widget.tab) {
      setState(() => _currentTab = widget.tab);
    }
  }

  void _onTabSelected(int index) {
    if (index == _currentTab) return;
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConnectivityBanner(
        child: IndexedStack(
          index: _currentTab,
          children: _screens,
        ),
      ),
      bottomNavigationBar: AnimatedBottomNavBar(
        items: _tabs,
        currentIndex: _currentTab,
        onTap: _onTabSelected,
      ),
    );
  }
}

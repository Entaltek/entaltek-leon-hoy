import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../storage/secure_storage_impl.dart';
import '../widgets/home_scaffold.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final storage = ref.read(secureStorageProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) async {
      final path = state.matchedLocation;

      // Splash y onboarding nunca redirigen.
      if (path == '/' || path == '/onboarding') return null;

      final token = await storage.getAccessToken();
      final isAuthenticated = token != null;
      final isAuthRoute = path == '/login' || path == '/register';

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/home/map';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      // Shell de home con 3 tabs: mapa, lista, favoritos.
      ShellRoute(
        builder: (context, state, child) {
          final tab = switch (state.matchedLocation) {
            '/home/map' => 0,
            '/home/list' => 1,
            '/home/favorites' => 2,
            _ => 0,
          };
          return HomeScaffold(tab: tab);
        },
        routes: [
          GoRoute(
            path: '/home/map',
            builder: (_, __) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: '/home/list',
            builder: (_, __) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: '/home/favorites',
            builder: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    ],
  );
}

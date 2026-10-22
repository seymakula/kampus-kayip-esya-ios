import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/create_item/create_item_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/item_detail/item_detail_screen.dart';
import '../../features/messages/messages_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/onboarding/onboarding_prefs.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/search/search_screen.dart';
import '../shell/main_shell.dart';
import 'app_routes.dart';

GoRouter createAppRouter({
  required OnboardingPrefs onboardingPrefs,
  String initialLocation = AppRoutes.home,
}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    // Tanıtım görülmediyse her yol önce tanıtıma gider.
    // Hafta 3'te oturum kontrolü (giriş yoksa /login) de buraya eklenecek.
    redirect: (context, state) {
      final atOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!onboardingPrefs.seen) {
        return atOnboarding ? null : AppRoutes.onboarding;
      }
      return atOnboarding ? AppRoutes.home : null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => OnboardingScreen(
          onFinished: () async {
            await onboardingPrefs.markSeen();
            if (context.mounted) context.go(AppRoutes.home);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // 5 sekmeli alt menü. Her sekme kendi gezinme yığınını ve
      // kaydırma konumunu korur (IndexedStack).
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.search,
              builder: (context, state) => const SearchScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.createItem,
              builder: (context, state) => const CreateItemScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.messages,
              builder: (context, state) => const MessagesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ]),
        ],
      ),

      // Alt menünün üstünde tam ekran açılan sayfalar.
      GoRoute(
        path: AppRoutes.itemDetailPattern,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => ItemDetailScreen(
          itemId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}

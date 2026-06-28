import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/routes.dart';
import '../navigation/main_shell.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/title/screens/title_generator_screen.dart';
import '../../features/hashtags/screens/hashtag_generator_screen.dart';
import '../../features/description/screens/description_generator_screen.dart';
import '../../features/content/screens/content_generator_screen.dart';
import '../../features/viral_ideas/screens/viral_ideas_screen.dart';
import '../../features/trending/screens/trending_screen.dart';
import '../../features/thumbnail/screens/thumbnail_generator_screen.dart';
import '../../features/seo/screens/seo_analysis_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/history/screens/history_detail_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

/// Provides the GoRouter configuration.
/// Watches the auth state to redirect unauthenticated users.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: _AuthRefreshNotifier(),
    redirect: (context, state) {
      final isLoggedIn = authState.maybeWhen(
        data: (user) => user != null,
        orElse: () => false,
      );
      final isOnSplash = state.matchedLocation == AppRoutes.splash;
      final isOnLogin = state.matchedLocation == AppRoutes.login;
      final isPublicRoute = isOnSplash || isOnLogin;

      // Still resolving auth → stay on splash.
      if (authState.isLoading || authState.isRefreshing) {
        return isOnSplash ? null : AppRoutes.splash;
      }

      // Unauthenticated on a protected route → login.
      if (!isLoggedIn && !isPublicRoute) {
        return AppRoutes.login;
      }

      // Returning authenticated user sitting on splash → home.
      // (We intentionally allow logged-in guests to open /login so they can
      // upgrade to a real account.)
      if (isLoggedIn && isOnSplash) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const MainShell(),
      ),
      // Feature routes — point to ComingSoonScreen until each is implemented.
      GoRoute(
        path: AppRoutes.title,
        name: 'title',
        builder: (context, state) => const TitleGeneratorScreen(),
      ),
      GoRoute(
        path: AppRoutes.hashtags,
        name: 'hashtags',
        builder: (context, state) => const HashtagGeneratorScreen(),
      ),
      GoRoute(
        path: AppRoutes.description,
        name: 'description',
        builder: (context, state) => const DescriptionGeneratorScreen(),
      ),
      GoRoute(
        path: AppRoutes.content,
        name: 'content',
        builder: (context, state) => const ContentGeneratorScreen(),
      ),
      GoRoute(
        path: AppRoutes.viralIdeas,
        name: 'viralIdeas',
        builder: (context, state) => const ViralIdeasScreen(),
      ),
      GoRoute(
        path: AppRoutes.trending,
        name: 'trending',
        builder: (context, state) => const TrendingScreen(),
      ),
      GoRoute(
        path: AppRoutes.thumbnail,
        name: 'thumbnail',
        builder: (context, state) => const ThumbnailGeneratorScreen(),
      ),
      GoRoute(
        path: AppRoutes.seo,
        name: 'seo',
        builder: (context, state) => const SeoAnalysisScreen(),
      ),
      GoRoute(
        path: AppRoutes.history,
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.historyDetail,
        name: 'historyDetail',
        builder: (context, state) => HistoryDetailScreen(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(child: Text('No route for ${state.matchedLocation}')),
    ),
  );

  // Refresh the router whenever auth state changes.
  ref.listen<AuthState>(authStateProvider, (_, __) {
    router.refresh();
  });

  return router;
});

/// A simple [ChangeNotifier] used as a [GoRouter.refreshListenable].
/// The actual refresh is triggered via `ref.listen` above; this notifier
/// is a placeholder to satisfy the API (can be removed in newer go_router).
class _AuthRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

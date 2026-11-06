import 'package:flutter/foundation.dart';
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
import '../../features/hook/screens/hook_generator_screen.dart';
import '../../features/captions/screens/captions_generator_screen.dart';
import '../../features/chapters/screens/chapters_generator_screen.dart';
import '../../features/cta/screens/cta_generator_screen.dart';
import '../../features/competitor/screens/competitor_rewriter_screen.dart';
import '../../features/series/screens/series_generator_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/history/screens/history_detail_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/channel_profile/screens/channel_profile_screen.dart';

/// Provides the GoRouter configuration.
///
/// The router is built ONCE. We intentionally do NOT `ref.watch` the auth state
/// here — watching would rebuild this provider and construct a brand-new
/// GoRouter on every auth change, discarding navigation state. Instead a single
/// [_AuthRefreshNotifier] bridges auth changes to `GoRouter`'s refreshListenable,
/// which re-runs `redirect`; redirect reads the latest auth via `ref.read`.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    // Route logging only in debug — avoids leaking navigation state and route
    // parameters (e.g. history item ids) to logcat in release builds.
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.maybeWhen(
        data: (user) => user != null,
        orElse: () => false,
      );
      final isOnSplash = state.matchedLocation == AppRoutes.splash;
      final isOnLogin = state.matchedLocation == AppRoutes.login;

      // Still resolving auth → stay on splash.
      if (authState.isLoading || authState.isRefreshing) {
        return isOnSplash ? null : AppRoutes.splash;
      }

      // Auth resolved and signed out → login. The only public route a
      // signed-out user may stay on is /login itself; in particular the
      // splash must hand over to login instead of spinning forever.
      if (!isLoggedIn) {
        return isOnLogin ? null : AppRoutes.login;
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
        path: AppRoutes.hook,
        name: 'hook',
        builder: (context, state) => const HookGeneratorScreen(),
      ),
      GoRoute(
        path: AppRoutes.captions,
        name: 'captions',
        builder: (context, state) => const CaptionsGeneratorScreen(),
      ),
      GoRoute(
        path: AppRoutes.chapters,
        name: 'chapters',
        builder: (context, state) => const ChaptersGeneratorScreen(),
      ),
      GoRoute(
        path: AppRoutes.cta,
        name: 'cta',
        builder: (context, state) => const CtaGeneratorScreen(),
      ),
      GoRoute(
        path: AppRoutes.competitor,
        name: 'competitor',
        builder: (context, state) => const CompetitorRewriterScreen(),
      ),
      GoRoute(
        path: AppRoutes.series,
        name: 'series',
        builder: (context, state) => const SeriesGeneratorScreen(),
      ),
      GoRoute(
        path: AppRoutes.history,
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.historyDetail,
        name: 'historyDetail',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null || id.isEmpty) {
            return const _RouteNotFoundScreen();
          }
          return HistoryDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.channelProfile,
        name: 'channelProfile',
        builder: (context, state) => const ChannelProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        _RouteNotFoundScreen(location: state.matchedLocation),
  );

  return router;
});

/// Fallback screen for malformed deep links and unknown routes — shown
/// instead of crashing on a missing/empty path parameter.
class _RouteNotFoundScreen extends StatelessWidget {
  const _RouteNotFoundScreen({this.location});

  final String? location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Text(
          location == null
              ? 'This page is not available.'
              : 'No route for $location',
        ),
      ),
    );
  }
}

/// Bridges Riverpod auth-state changes to [GoRouter.refreshListenable].
///
/// Subscribes to [authStateProvider] and calls [notifyListeners] on each change,
/// prompting GoRouter to re-evaluate `redirect`. The subscription is closed when
/// the router provider is disposed (see `ref.onDispose`).
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    _subscription = ref.listen<AuthState>(
      authStateProvider,
      (_, __) => notifyListeners(),
    );
  }

  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

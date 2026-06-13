import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/session/session_controller.dart';
import '../../core/session/session_state.dart';
import '../../features/auth/presentation/scope/auth_scope.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../shared/widgets/app_shell.dart';
import 'routes.dart';
import 'session_refresh_listenable.dart';

GoRouter buildRouter(SessionController session) => GoRouter(
  initialLocation: Routes.splash,
  refreshListenable: SessionRefreshListenable(session),
  redirect: (context, state) {
    final s = session.state;
    final path = state.matchedLocation;

    if (s is SessionUnknown) return Routes.splash;

    if (s is SessionUnauthenticated) {
      final publicPaths = [Routes.login, Routes.register, Routes.splash];
      if (!publicPaths.contains(path)) return Routes.login;
    }

    if (s is SessionAuthenticated) {
      final authOnlyPaths = [Routes.login, Routes.register, Routes.splash];
      if (authOnlyPaths.contains(path)) return Routes.home;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (_, __) =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    ),
    GoRoute(
      path: Routes.login,
      builder: (_, __) =>
          const AuthScopeHolder(child: LoginScreen()),
    ),
    GoRoute(
      path: Routes.register,
      builder: (_, __) =>
          const AuthScopeHolder(child: RegisterScreen()),
    ),
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.home,
              builder: (_, __) =>
                  const Scaffold(body: Center(child: Text('Home'))),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.search,
              builder: (_, __) =>
                  const Scaffold(body: Center(child: Text('Search'))),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.notifications,
              builder: (_, __) =>
                  const Scaffold(body: Center(child: Text('Notifications'))),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.profile,
              builder: (_, __) =>
                  const Scaffold(body: Center(child: Text('Profile'))),
            ),
          ],
        ),
      ],
    ),
  ],
);

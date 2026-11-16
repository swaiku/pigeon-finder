import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/onboarding_cubit.dart';
import '../../features/auth/presentation/pages/code_page.dart';
import '../../features/auth/presentation/pages/email_page.dart';
import '../../features/auth/presentation/pages/location_page.dart';
import '../../features/auth/presentation/pages/pseudo_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/map/presentation/pages/map_page.dart';
import '../../features/pigeondex/presentation/bloc/pigeondex_cubit.dart';
import '../../features/pigeondex/presentation/pages/pigeondex_page.dart';
import '../../features/post/presentation/bloc/post_cubit.dart';
import '../../features/post/presentation/pages/camera_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/ranking/presentation/pages/ranking_page.dart';
import '../di/injection.dart';
import '../widgets/main_shell.dart';

abstract final class AppRoutes {
  static const map = '/map';
  static const pigeondex = '/pigeondex';
  static const ranking = '/ranking';
  static const profile = '/profile';
  static const camera = '/camera';
  static const authWelcome = '/auth/welcome';
  static const authEmail = '/auth/email';
  static const authCode = '/auth/code';
  static const authPseudo = '/auth/pseudo';
  static const authLocation = '/auth/location';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.map,
  redirect: (_, state) {
    final auth = sl<AuthRepository>();
    final inAuth = state.matchedLocation.startsWith('/auth');
    if (!auth.isSignedIn) return inAuth ? null : AppRoutes.authWelcome;
    // Signed in but never picked a pseudo, e.g. the app was closed mid-flow.
    if (!auth.hasProfile && !inAuth) return AppRoutes.authPseudo;
    return null;
  },
  routes: [
    // One cubit for the whole sign-up / login flow.
    ShellRoute(
      builder: (_, _, child) =>
          BlocProvider(create: (_) => sl<OnboardingCubit>(), child: child),
      routes: [
        GoRoute(
          path: AppRoutes.authWelcome,
          builder: (_, _) => const WelcomePage(),
        ),
        GoRoute(
          path: AppRoutes.authEmail,
          builder: (_, _) => const EmailPage(),
        ),
        GoRoute(path: AppRoutes.authCode, builder: (_, _) => const CodePage()),
        GoRoute(
          path: AppRoutes.authPseudo,
          builder: (_, _) => const PseudoPage(),
        ),
        GoRoute(
          path: AppRoutes.authLocation,
          builder: (_, _) => const LocationPage(),
        ),
      ],
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: AppRoutes.map, builder: (_, _) => const MapPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.pigeondex,
              builder: (_, _) => BlocProvider(
                create: (_) {
                  final cubit = sl<PigeondexCubit>();
                  unawaited(cubit.load());
                  return cubit;
                },
                child: const PigeondexPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.ranking,
              builder: (_, _) => const RankingPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (_, _) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
    // Full screen, above the bottom bar.
    GoRoute(
      path: AppRoutes.camera,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, _) => BlocProvider(
        // Not lazy: the page only reads the cubit after the shot, but the
        // position should be looked up while the user frames it.
        lazy: false,
        create: (_) {
          final cubit = sl<PostCubit>();
          unawaited(cubit.prepare());
          return cubit;
        },
        child: const CameraPage(),
      ),
    ),
  ],
);

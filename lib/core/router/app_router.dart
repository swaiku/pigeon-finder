import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/map/presentation/pages/map_page.dart';
import '../../features/pigeondex/presentation/pages/pigeondex_page.dart';
import '../../features/post/presentation/pages/camera_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/ranking/presentation/pages/ranking_page.dart';
import '../widgets/main_shell.dart';

abstract final class AppRoutes {
  static const map = '/map';
  static const pigeondex = '/pigeondex';
  static const ranking = '/ranking';
  static const profile = '/profile';
  static const camera = '/camera';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.map,
  routes: [
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
              builder: (_, _) => const PigeondexPage(),
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
      builder: (_, _) => const CameraPage(),
    ),
  ],
);

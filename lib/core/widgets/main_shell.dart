import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../router/app_router.dart';
import 'pf_bottom_nav_bar.dart';

/// Scaffold hosting the tab branches and the bottom navigation bar.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: PfBottomNavBar(
        items: [
          PfNavItem(icon: Icons.map_outlined, label: l10n.navMap),
          PfNavItem(icon: Icons.grid_view_outlined, label: l10n.navPigeondex),
          PfNavItem(icon: Icons.emoji_events_outlined, label: l10n.navRanking),
          PfNavItem(icon: Icons.person_outline, label: l10n.navProfile),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        centerIcon: Icons.camera_alt_outlined,
        onCenterTap: () => context.push(AppRoutes.camera),
      ),
    );
  }
}

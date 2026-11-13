import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pf_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/onboarding_cubit.dart';

/// Asks for the location permission once, with a reason, before the system
/// dialog. Refusing is fine: the map falls back on a default view.
class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  Future<void> _allow() async {
    await context.read<OnboardingCubit>().requestLocation();
    if (mounted) context.go(AppRoutes.map);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.dangerContainer,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 80,
                  color: AppColors.pin,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                l10n.locationTitle,
                textAlign: TextAlign.center,
                style: theme.displayMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.locationSubtitle,
                textAlign: TextAlign.center,
                style: theme.bodyLarge?.copyWith(color: AppColors.mist),
              ),
              const Spacer(),
              PfButton(label: l10n.locationAllow, onPressed: _allow),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => context.go(AppRoutes.map),
                child: Text(l10n.locationLater),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

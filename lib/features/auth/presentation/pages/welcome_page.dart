import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pf_button.dart';
import '../../../../core/widgets/pf_card.dart';
import '../../../../l10n/app_localizations.dart';

class const WelcomePage({super.key}) extends StatelessWidget {
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
              const SizedBox(height: AppSpacing.xxxl * 2),
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset(
                  'assets/icon/icon.png',
                  width: 150,
                  height: 150,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.appTitle, style: theme.displayLarge),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.authWelcomeSubtitle,
                textAlign: TextAlign.center,
                style: theme.bodyLarge?.copyWith(color: AppColors.mist),
              ),
              const SizedBox(height: AppSpacing.xxl),
              PfCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _Step(1, AppColors.pin, l10n.authStep1),
                    const SizedBox(height: AppSpacing.md),
                    _Step(2, AppColors.iridescent, l10n.authStep2),
                    const SizedBox(height: AppSpacing.md),
                    _Step(3, AppColors.night, l10n.authStep3),
                  ],
                ),
              ),
              const Spacer(),
              PfButton(
                label: l10n.authContinueWithEmail,
                onPressed: () => context.push(AppRoutes.authEmail),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.authNoPassword,
                style: theme.bodySmall?.copyWith(color: AppColors.mist),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class const _Step(final int number, final Color color, final String text)
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Row(
      children: [
        CircleAvatar(
          radius: AppSpacing.avatarSm / 2,
          backgroundColor: color,
          child: Text(
            '$number',
            style: theme.bodyLarge?.copyWith(color: AppColors.paper),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(text, style: theme.bodyLarge)),
      ],
    );
  }
}

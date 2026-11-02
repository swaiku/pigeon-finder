import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pf_button.dart';
import '../../../../core/widgets/pf_checkbox_row.dart';
import '../../../../core/widgets/pf_chip.dart';
import '../../../../core/widgets/pf_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/onboarding_cubit.dart';
import '../widgets/auth_scaffold.dart';

final _pseudoPattern = RegExp(r'^[a-zA-Z0-9_]{3,30}$');

class PseudoPage extends StatefulWidget {
  const PseudoPage({super.key});

  @override
  State<PseudoPage> createState() => _PseudoPageState();
}

class _PseudoPageState extends State<PseudoPage> {
  final _controller = TextEditingController();
  var _acceptTerms = false;
  var _trainingConsent = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final saved = await context.read<OnboardingCubit>().saveProfile(
      pseudo: _controller.text.trim(),
      trainingConsent: _trainingConsent,
    );
    if (saved && mounted) context.go(AppRoutes.authLocation);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;
    final state = context.watch<OnboardingCubit>().state;
    final ready =
        _acceptTerms &&
        _pseudoPattern.hasMatch(_controller.text.trim()) &&
        !state.isLoading;
    return AuthScaffold(
      leading: Align(
        alignment: Alignment.centerLeft,
        child: PfStatusChip(
          label: l10n.authEmailVerified,
          tone: PfChipTone.success,
        ),
      ),
      title: l10n.authPseudoTitle,
      subtitle: Text(l10n.authPseudoSubtitle),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.authPseudoLabel, style: theme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          PfTextField(
            controller: _controller,
            hintText: l10n.authPseudoHint,
            prefixText: '@  ',
            maxLength: 30,
            autofocus: true,
            onChanged: (_) => setState(() {}),
          ),
          if (state.status == OnboardingStatus.failure ||
              state.status == OnboardingStatus.usernameTaken) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.status == OnboardingStatus.usernameTaken
                  ? l10n.authUsernameTaken
                  : l10n.authError,
              style: theme.bodySmall?.copyWith(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          PfCheckboxRow(
            value: _acceptTerms,
            onChanged: (v) => setState(() => _acceptTerms = v),
            label: l10n.authAcceptTerms,
          ),
          const SizedBox(height: AppSpacing.md),
          PfCheckboxRow(
            value: _trainingConsent,
            onChanged: (v) => setState(() => _trainingConsent = v),
            label: l10n.authTrainingConsent,
          ),
          const SizedBox(height: AppSpacing.xl),
          PfButton(label: l10n.authLetsGo, onPressed: ready ? _submit : null),
        ],
      ),
    );
  }
}

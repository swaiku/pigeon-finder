import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pf_back_button.dart';
import '../../../../core/widgets/pf_button.dart';
import '../../../../core/widgets/pf_otp_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/onboarding_cubit.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/cooldown.dart';

const _codeLength = 6;

class CodePage extends StatefulWidget {
  const CodePage({super.key});

  @override
  State<CodePage> createState() => _CodePageState();
}

class _CodePageState extends State<CodePage> {
  var _code = '';
  var _verifyFailed = false;

  Future<void> _resend() {
    final cubit = context.read<OnboardingCubit>();
    return cubit.sendCode(cubit.state.email);
  }

  Future<void> _verify() async {
    final cubit = context.read<OnboardingCubit>();
    final ok = await cubit.verifyCode(_code);
    if (!mounted) return;
    setState(() => _verifyFailed = !ok);
    if (ok) context.go(cubit.hasProfile ? AppRoutes.map : AppRoutes.authPseudo);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;
    final state = context.watch<OnboardingCubit>().state;
    return AuthScaffold(
      leading: const PfBackButton(),
      title: l10n.authCodeTitle,
      subtitle: Wrap(
        children: [
          Text(l10n.authCodeSentTo(state.email)),
          InkWell(
            onTap: context.pop,
            child: Text(
              ' · ${l10n.authEdit}',
              style: const TextStyle(color: AppColors.pin),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          PfOtpField(onChanged: (v) => setState(() => _code = v)),
          if (_verifyFailed) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.authCodeInvalid,
              style: theme.bodySmall?.copyWith(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Cooldown(
            until: state.retryUntil,
            builder: (_, timeLeft) => timeLeft != null
                ? Text(
                    l10n.authResendIn(timeLeft),
                    style: theme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
                  )
                : TextButton(
                    onPressed: state.isLoading ? null : _resend,
                    child: Text(l10n.authResend),
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PfButton(
            label: l10n.authValidate,
            onPressed: _code.length == _codeLength && !state.isLoading
                ? _verify
                : null,
          ),
        ],
      ),
      note: l10n.authCodeHelp,
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pf_back_button.dart';
import '../../../../core/widgets/pf_button.dart';
import '../../../../core/widgets/pf_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/onboarding_cubit.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/cooldown.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class EmailPage extends StatefulWidget {
  const EmailPage({super.key});

  @override
  State<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final sent = await context.read<OnboardingCubit>().sendCode(
      _controller.text.trim(),
    );
    if (sent && mounted) await context.push(AppRoutes.authCode);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<OnboardingCubit>().state;
    final email = _controller.text.trim();
    final valid = _emailPattern.hasMatch(email);
    return AuthScaffold(
      leading: const PfBackButton(),
      title: l10n.authEmailTitle,
      subtitle: Text(l10n.authEmailSubtitle),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PfTextField(
            controller: _controller,
            hintText: l10n.authEmailHint,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            onChanged: (_) => setState(() {}),
          ),
          if (state.status == OnboardingStatus.failure) ...[
            const SizedBox(height: 8),
            Text(
              l10n.authError,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: 22),
          // A new address is not covered by the limit on the previous one.
          Cooldown(
            until: email == state.email ? state.retryUntil : null,
            builder: (_, timeLeft) => Column(
              children: [
                PfButton(
                  label: l10n.authReceiveCode,
                  onPressed: valid && !state.isLoading && timeLeft == null
                      ? _submit
                      : null,
                ),
                if (timeLeft != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.authResendIn(timeLeft),
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AppColors.mutedText),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      note: l10n.authEmailPrivacy,
    );
  }
}

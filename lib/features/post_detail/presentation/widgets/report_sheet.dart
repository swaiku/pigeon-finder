import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

const _radioSize = 20.0;
const _radioDotSize = 10.0;
const _borderWidth = 2.0;

/// Distance a row travels while sliding in.
const _slideDistance = 14.0;

enum ReportReason { notPigeon, gull, stolen, inappropriate }

/// Opens the "What's wrong?" popup. Resolves with the picked reason, or null
/// when dismissed.
Future<ReportReason?> showReportSheet(BuildContext context) {
  return showModalBottomSheet<ReportReason>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: AppColors.paper,
    barrierColor: AppColors.scrimModal,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusSheet),
      ),
    ),
    builder: (_) => const _ReportSheet(),
  );
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet();

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  ReportReason? _reason;

  String _label(AppLocalizations l10n, ReportReason r) => switch (r) {
    ReportReason.notPigeon => l10n.reportReasonNotPigeon,
    ReportReason.gull => l10n.reportReasonGull,
    ReportReason.stolen => l10n.reportReasonStolen,
    ReportReason.inappropriate => l10n.reportReasonInappropriate,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = Theme.of(context).textTheme;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.roomy,
        AppSpacing.xl,
        AppSpacing.roomy,
        bottom + AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.reportTitle, style: text.headlineLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.reportSubtitle,
            style: text.bodyMedium?.copyWith(color: AppColors.mist),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final (i, r) in ReportReason.values.indexed)
            _ReasonTile(
              // Rows slide in one after the other.
              delay: AppMotion.stagger * i,
              label: _label(l10n, r),
              selected: _reason == r,
              onTap: () => setState(() => _reason = r),
            ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: _reason == null
                ? null
                : () => Navigator.of(context).pop(_reason),
            child: AnimatedContainer(
              duration: AppMotion.fast,
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(AppSpacing.lg),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _reason == null ? AppColors.mutedText : AppColors.pin,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              ),
              child: Text(
                l10n.reportSubmit,
                style: text.titleLarge?.copyWith(color: AppColors.paper),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.delay,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Duration delay;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = selected ? AppColors.pin : AppColors.trait;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.medium + delay,
      curve: Curves.easeOutCubic,
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, _slideDistance * (1 - t)),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            padding: const EdgeInsets.all(AppSpacing.cozy),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
              border: Border.all(color: border, width: _borderWidth),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: AppMotion.fast,
                  width: _radioSize,
                  height: _radioSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: border, width: _borderWidth),
                  ),
                  alignment: Alignment.center,
                  child: AnimatedScale(
                    scale: selected ? 1 : 0,
                    duration: AppMotion.fast,
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: _radioDotSize,
                      height: _radioDotSize,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.pin,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

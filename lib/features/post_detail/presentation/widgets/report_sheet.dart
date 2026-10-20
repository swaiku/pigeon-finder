import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

enum ReportReason { notPigeon, gull, stolen, inappropriate }

/// Opens the "What's wrong?" popup. Resolves with the picked reason, or null
/// when dismissed.
Future<ReportReason?> showReportSheet(BuildContext context) {
  return showModalBottomSheet<ReportReason>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: AppColors.paper,
    barrierColor: AppColors.scrim.withAlpha(0x73),
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
      padding: EdgeInsets.fromLTRB(18, 22, 18, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.reportTitle,
            style: text.titleLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.reportSubtitle,
            style: text.bodyMedium?.copyWith(color: AppColors.mist),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final (i, r) in ReportReason.values.indexed)
            _ReasonTile(
              // Rows slide in one after the other.
              delay: i * 60,
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
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(AppSpacing.lg),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _reason == null
                    ? const Color(0xFFC9C2B4)
                    : AppColors.pin,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                l10n.reportSubmit,
                style: text.titleMedium?.copyWith(
                  color: AppColors.paper,
                  fontSize: 18,
                ),
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

  final int delay;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = selected ? AppColors.pin : AppColors.trait;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + delay),
      curve: Curves.easeOutCubic,
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - t)),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
              border: Border.all(color: border, width: 2),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: border, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: AnimatedScale(
                    scale: selected ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: 10,
                      height: 10,
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

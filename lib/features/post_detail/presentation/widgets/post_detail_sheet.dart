import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pf_avatar.dart';
import '../../../../core/widgets/pf_image_placeholder.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../map/domain/entities/map_post.dart';
import 'report_sheet.dart';

/// Opens the post detail as a bottom sheet over the map.
Future<void> showPostDetailSheet(BuildContext context, MapPost post) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: AppColors.paper,
    barrierColor: AppColors.scrim.withAlpha(0x59),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusSheet),
      ),
    ),
    builder: (_) => PostDetailSheet(post: post),
  );
}

/// Photo, author, points and the coo / report actions of one post.
class PostDetailSheet extends StatefulWidget {
  const PostDetailSheet({super.key, required this.post});

  final MapPost post;

  @override
  State<PostDetailSheet> createState() => _PostDetailSheetState();
}

class _PostDetailSheetState extends State<PostDetailSheet>
    with TickerProviderStateMixin {
  late final _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  // TODO(post-detail): persist coos and reports through a repository.
  bool _cooed = false;
  bool _reported = false;

  MapPost get _post => widget.post;

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  /// Fades and lifts a block in, between [from] and [to] of the entrance.
  Widget _stagger(double from, double to, Widget child) {
    final curve = CurvedAnimation(
      parent: _enter,
      curve: Interval(from, to, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, .25),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  Future<void> _report() async {
    final reason = await showReportSheet(context);
    if (reason == null || !mounted) return;
    unawaited(HapticFeedback.mediumImpact());
    setState(() => _reported = true);
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.postDetailReportThanks),
      ),
    );
  }

  String _ago(AppLocalizations l10n) {
    final age = DateTime.now().difference(_post.createdAt);
    return age.inHours >= 1
        ? l10n.postDetailAgoHours(age.inHours)
        : l10n.postDetailAgoMinutes(age.inMinutes);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = Theme.of(context).textTheme;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final left = _post.timeLeft();
    final reports = _post.reports + (_reported ? 1 : 0);
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 10, 18, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.trait,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _stagger(
            0,
            .55,
            ScaleTransition(
              // The photo settles in as the sheet arrives.
              scale: Tween(begin: .94, end: 1.0).animate(
                CurvedAnimation(
                  parent: _enter,
                  curve: const Interval(0, .55, curve: Curves.easeOutBack),
                ),
              ),
              child: SizedBox(
                height: 230,
                child: PfImagePlaceholder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPanel),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: _PigeonCountPill(count: _post.count),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: _PhotoBadge(
                          label: l10n.mapExpiresIn(
                            left.inHours,
                            left.inMinutes % 60,
                          ),
                          background: AppColors.scrim.withAlpha(0x99),
                          foreground: Colors.white,
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 10,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) => ScaleTransition(
                            scale: CurvedAnimation(
                              parent: anim,
                              curve: Curves.easeOutBack,
                            ),
                            child: child,
                          ),
                          child: reports > 0
                              ? _PhotoBadge(
                                  key: ValueKey(reports),
                                  label: l10n.mapReports(reports),
                                  background: AppColors.grain,
                                  foreground: AppColors.night,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _stagger(
            .2,
            .75,
            Row(
              children: [
                PfAvatar(
                  initial: _post.user[0].toUpperCase(),
                  size: 44,
                  backgroundColor: AppColors.feather,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _post.user,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium,
                      ),
                      Text(
                        '${_post.place} · ${_ago(l10n)}',
                        overflow: TextOverflow.ellipsis,
                        style: text.labelLarge?.copyWith(color: AppColors.mist),
                      ),
                    ],
                  ),
                ),
                // Points count up while the sheet settles.
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: _post.points),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => Text(
                    '+$v',
                    style: text.titleMedium?.copyWith(
                      color: AppColors.iridescent,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _CooButton(
                  label: l10n.postDetailCoo(_post.coos + (_cooed ? 1 : 0)),
                  active: _cooed,
                  onTap: () {
                    unawaited(HapticFeedback.lightImpact());
                    setState(() => _cooed = !_cooed);
                  },
                ),
              ),
              if (!_post.mine) ...[
                const SizedBox(width: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SizeTransition(
                      axis: Axis.horizontal,
                      sizeFactor: anim,
                      child: child,
                    ),
                  ),
                  child: _reported
                      ? _ReportedPill(
                          key: const ValueKey('reported'),
                          label: l10n.postDetailReported,
                        )
                      : _ReportButton(
                          key: const ValueKey('report'),
                          label: l10n.postDetailReport,
                          onTap: _report,
                        ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PhotoBadge extends StatelessWidget {
  const _PhotoBadge({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: foreground),
      ),
    );
  }
}

/// Heart button: colour cross-fades and the icon pops when toggled on.
class _CooButton extends StatefulWidget {
  const _CooButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_CooButton> createState() => _CooButtonState();
}

class _CooButtonState extends State<_CooButton>
    with SingleTickerProviderStateMixin {
  late final _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.5,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.5,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 65,
    ),
  ]).animate(_pop);

  bool _down = false;

  @override
  void didUpdateWidget(_CooButton old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) _pop.forward(from: 0);
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.active ? AppColors.pin : AppColors.dangerContainer;
    final fg = widget.active ? Colors.white : AppColors.danger;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? .97 : 1,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Icon(Icons.favorite, size: 20, color: fg),
              ),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: Theme.of(context).textTheme.titleSmall!
                    .copyWith(color: fg),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pigeon count shown as a pill on the photo.
class _PigeonCountPill extends StatelessWidget {
  const _PigeonCountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 6),
          Text(
            '×$count',
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: AppColors.night, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ReportButton extends StatelessWidget {
  const _ReportButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          border: Border.all(color: AppColors.trait, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flag_outlined, size: 18, color: AppColors.night),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: AppColors.night),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportedPill extends StatelessWidget {
  const _ReportedPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: AppColors.onWarningContainer),
      ),
    );
  }
}

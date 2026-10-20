import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pf_avatar.dart';
import '../../../../core/widgets/pf_photo.dart';
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
    barrierColor: AppColors.scrimModal,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusSheet),
      ),
    ),
    builder: (_) => PostDetailSheet(post: post),
  );
}

const _sheetHandle = Size(40, 5);
const _photoHeight = 230.0;
const _badgeInset = 10.0;
const _pillInset = 12.0;

/// Entrance timeline, as fractions of [AppMotion.entrance].
const _photoEnd = .55;
const _authorStart = .2;
const _authorEnd = .75;
const _photoStartScale = .94;
const _staggerLift = Offset(0, .25);

/// Scale reached at the peak of the coo heart's pop.
const _cooPopScale = 1.5;
const _cooPressedScale = .97;

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
    duration: AppMotion.entrance,
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
        position: Tween(begin: _staggerLift, end: Offset.zero).animate(curve),
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
      padding: EdgeInsets.fromLTRB(
        AppSpacing.roomy,
        AppSpacing.snug,
        AppSpacing.roomy,
        bottom + AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: _sheetHandle.width,
              height: _sheetHandle.height,
              decoration: BoxDecoration(
                color: AppColors.trait,
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.cozy),
          _stagger(
            0,
            _photoEnd,
            ScaleTransition(
              // The photo settles in as the sheet arrives.
              scale: Tween(begin: _photoStartScale, end: 1.0).animate(
                CurvedAnimation(
                  parent: _enter,
                  curve: const Interval(
                    0,
                    _photoEnd,
                    curve: Curves.easeOutBack,
                  ),
                ),
              ),
              child: SizedBox(
                height: _photoHeight,
                child: PfPhoto(
                  url: _post.photoUrl,
                  cacheWidth: MediaQuery.sizeOf(context).width,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPanel),
                  child: Stack(
                    children: [
                      Positioned(
                        left: _pillInset,
                        bottom: _pillInset,
                        child: _PigeonCountPill(count: _post.count),
                      ),
                      Positioned(
                        right: _badgeInset,
                        top: _badgeInset,
                        child: _PhotoBadge(
                          label: l10n.mapExpiresIn(
                            left.inHours,
                            left.inMinutes % 60,
                          ),
                          background: AppColors.scrimBadge,
                          foreground: Colors.white,
                        ),
                      ),
                      Positioned(
                        left: _badgeInset,
                        top: _badgeInset,
                        child: AnimatedSwitcher(
                          duration: AppMotion.medium,
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
          const SizedBox(height: AppSpacing.cozy),
          _stagger(
            _authorStart,
            _authorEnd,
            Row(
              children: [
                PfAvatar(
                  initial: _post.user[0].toUpperCase(),
                  size: AppSpacing.avatarMd,
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
                  duration: AppMotion.countUp,
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => Text(
                    '+$v',
                    style: text.titleLarge?.copyWith(
                      color: AppColors.iridescent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.cozy),
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
                const SizedBox(width: AppSpacing.snug),
                AnimatedSwitcher(
                  duration: AppMotion.medium,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.snug,
        vertical: AppSpacing.xs,
      ),
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
    duration: AppMotion.emphasis,
  );
  late final _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: _cooPopScale,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: _cooPopScale,
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
        scale: _down ? _cooPressedScale : 1,
        duration: AppMotion.press,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.cozy),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Icon(Icons.favorite, size: AppSpacing.iconMd, color: fg),
              ),
              const SizedBox(width: AppSpacing.sm),
              AnimatedDefaultTextStyle(
                duration: AppMotion.fast,
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: AppSpacing.compact),
          Text(
            '×$count',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: AppColors.night),
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.cozy,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          border: Border.all(color: AppColors.trait, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.flag_outlined,
              size: AppSpacing.iconSm,
              color: AppColors.night,
            ),
            const SizedBox(width: AppSpacing.compact),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.cozy,
      ),
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

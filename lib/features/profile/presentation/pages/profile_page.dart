import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pf_avatar.dart';
import '../../../../core/widgets/pf_button.dart';
import '../../../../core/widgets/pf_card.dart';
import '../../../../core/widgets/pf_chip.dart';
import '../../../../core/widgets/pf_error_state.dart';
import '../../../../core/widgets/pf_loading_indicator.dart';
import '../../../../core/widgets/pf_photo.dart';
import '../../../../core/widgets/pf_progress_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../map/domain/entities/map_post.dart';
import '../../../post_detail/presentation/widgets/post_detail_sheet.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/profile_badge.dart';
import '../bloc/profile_cubit.dart';

const _margin = AppSpacing.lg;
const _sectionGap = AppSpacing.xxl;
const _avatarSize = 76.0;
const _dialogAvatarSize = 180.0;
const _thumbSize = 54.0;

/// Avatars are shown small: no need to upload a full-size photo.
const _avatarMaxPixels = 512.0;
const _avatarQuality = 85;

/// How long the streak tooltip stays up after a tap.
const _tooltipDuration = Duration(seconds: 4);

/// The user's level, stats, photos still on the map and badges.
class const ProfilePage({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProfileCubit>();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) => switch (state) {
            ProfileState(status: ProfileStatus.ready, :final profile?) =>
              RefreshIndicator(
                onRefresh: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  if (await cubit.load()) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.postErrorNetwork)),
                  );
                },
                child: _Body(state: state, profile: profile),
              ),
            ProfileState(status: ProfileStatus.failure) => Center(
              child: PfErrorState(
                message: l10n.profileLoadError,
                actionLabel: l10n.retry,
                onAction: cubit.load,
              ),
            ),
            _ => const Center(child: PfLoadingIndicator()),
          },
        ),
      ),
    );
  }
}

class const _Body({
  required final ProfileState state,
  required final Profile profile,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = Theme.of(context).textTheme;
    final onMap = state.onMap();
    final earned = state.badges;
    Widget title(String label) => Padding(
      padding: const EdgeInsets.only(top: _sectionGap, bottom: AppSpacing.md),
      child: Semantics(
        header: true,
        child: Text(label, style: text.titleLarge),
      ),
    );
    return ListView(
      // Lets a short profile still be pulled to refresh.
      physics: const AlwaysScrollableScrollPhysics(),
      // The page extends under the floating bottom bar.
      padding: EdgeInsets.fromLTRB(
        _margin,
        AppSpacing.xl,
        _margin,
        MediaQuery.paddingOf(context).bottom + _margin,
      ),
      children: [
        _Header(
          profile: profile,
          place: state.lastPlace,
          uploading: state.uploadingAvatar,
        ),
        const SizedBox(height: _sectionGap),
        _LevelCard(state: state),
        const SizedBox(height: AppSpacing.lg),
        _Stats(state: state),
        if (onMap.isNotEmpty) ...[
          title(l10n.profileOnMapTitle),
          for (final post in onMap)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _OnMapRow(key: ValueKey(post.id), post: post),
            ),
        ],
        title(l10n.profileBadgesTitle),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final badge in ProfileBadge.values)
              PfStatusChip(
                label: l10n.profileBadge(badge.name),
                tone: earned.contains(badge)
                    ? PfChipTone.dark
                    : PfChipTone.neutral,
                filled: earned.contains(badge),
              ),
          ],
        ),
      ],
    );
  }
}

class const _Header({
  required final Profile profile,
  required final String place,
  required final bool uploading,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Semantics(
          // Its own node: the name and city beside it are not the button.
          container: true,
          button: true,
          label: l10n.profilePhotoLabel,
          // The initial would be read after the label; the tap stays here.
          onTap: uploading ? null : () => _showAvatarDialog(context, profile),
          excludeSemantics: true,
          child: GestureDetector(
            onTap: uploading ? null : () => _showAvatarDialog(context, profile),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.paper,
                shape: BoxShape.circle,
                boxShadow: AppSpacing.shadowCard,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PfAvatar(
                    initial: _initial(profile),
                    photoUrl: profile.avatarUrl,
                    size: _avatarSize,
                  ),
                  if (uploading) const PfLoadingIndicator(),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile.username, style: text.headlineMedium),
              if (place.isNotEmpty)
                Text(
                  place,
                  style: text.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

String _initial(Profile profile) => profile.username[0].toUpperCase();

/// Shows the current photo with a button to replace it from the camera or
/// the gallery.
Future<void> _showAvatarDialog(BuildContext context, Profile profile) async {
  final l10n = AppLocalizations.of(context)!;
  final cubit = context.read<ProfileCubit>();
  final messenger = ScaffoldMessenger.of(context);
  final change = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: AppColors.paper,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: l10n.profilePhotoLabel,
              image: true,
              child: PfAvatar(
                initial: _initial(profile),
                photoUrl: profile.avatarUrl,
                size: _dialogAvatarSize,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            PfButton(
              label: l10n.profileChangePhoto,
              icon: Icons.photo_camera_outlined,
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
        ),
      ),
    ),
  );
  if (change != true || !context.mounted) return;

  // Android's camera app cannot also offer the gallery, so the user picks.
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    useRootNavigator: true,
    backgroundColor: AppColors.paper,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.profileTakePhoto),
            onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.profilePickFromGallery),
            onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (source == null) return;

  final XFile? picked;
  try {
    // shortcut: a PNG from the gallery is uploaded as is with a JPEG content
    // type (it still displays), re-encode it if the bucket starts checking
    picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: _avatarMaxPixels,
      maxHeight: _avatarMaxPixels,
      imageQuality: _avatarQuality,
    );
  } on PlatformException {
    // Camera or photo access denied.
    messenger.showSnackBar(SnackBar(content: Text(l10n.cameraDenied)));
    return;
  }
  if (picked == null) return;
  if (!await cubit.changeAvatar(File(picked.path))) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.profileAvatarError)));
  }
}

class const _LevelCard({required final ProfileState state})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = Theme.of(context).textTheme;
    final onCard = Theme.of(context).colorScheme.onSecondary;
    final number = NumberFormat.decimalPattern(l10n.localeName);
    final xp = state.xp;
    final level = state.level;
    final next = level.next;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPanel),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.profileLevel(
                    l10n.profileLevelName(level.name),
                    level.number,
                  ),
                  style: text.titleLarge?.copyWith(color: onCard),
                ),
              ),
              Text(
                next == null
                    ? number.format(xp)
                    : '${number.format(xp)} / ${number.format(next.minXp)}',
                style: text.bodyMedium?.copyWith(color: onCard.withAlpha(0xCC)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          PfProgressBar(
            value: level.progress(xp),
            trackColor: onCard.withAlpha(0x33),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            next == null
                ? l10n.profileMaxLevel
                : l10n.profileNextLevel(l10n.profileLevelName(next.name)),
            style: text.bodyLarge?.copyWith(color: onCard.withAlpha(0xCC)),
          ),
        ],
      ),
    );
  }
}

class const _Stats({required final ProfileState state})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final photos = state.posts.length;
    final pigeons = state.pigeons;
    final streak = state.streak();
    // shortcut: the countdown only updates on rebuild or refresh, add a timer
    // tick like MapBloc if it must stay live
    final left = streak.expiresAt?.difference(DateTime.now());
    return Row(
      children: [
        Expanded(
          child: _StatTile(value: '$photos', label: l10n.profilePhotos(photos)),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatTile(
            value: '$pigeons',
            label: l10n.profilePigeons(pigeons),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Tooltip(
            message: left == null
                ? l10n.profileStreakNone
                : l10n.profileStreakExpires(
                    left.inHours,
                    left.inMinutes.remainder(60),
                  ),
            triggerMode: TooltipTriggerMode.tap,
            showDuration: _tooltipDuration,
            child: _StatTile(
              value: l10n.profileStreakDays(streak.days),
              label: l10n.profileStreak,
            ),
          ),
        ),
      ],
    );
  }
}

class const _StatTile({
  required final String value,
  required final String label,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PfCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: text.headlineMedium),
          ),
          Text(
            label,
            style: text.bodyMedium?.copyWith(color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}

class const _OnMapRow({super.key, required final MapPost post})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = Theme.of(context).textTheme;
    final left = post.timeLeft();
    // Rounded up: a fresh post reads "24 h", not "23 h".
    final hours = (left.inMinutes + 59) ~/ 60;
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: () => showPostDetailSheet(context, post),
        child: PfCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              SizedBox.square(
                dimension: _thumbSize,
                child: PfPhoto(url: post.photoUrl, cacheWidth: _thumbSize),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.place.isEmpty
                          ? l10n.pigeondexUnknownPlace
                          : post.place,
                      style: text.titleMedium,
                    ),
                    Text(
                      '${l10n.mapPigeonCount(post.count)} · '
                      '${l10n.profileExpiresIn(hours)}',
                      style: text.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '+${post.points}',
                style: text.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

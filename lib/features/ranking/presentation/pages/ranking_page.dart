import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pf_avatar.dart';
import '../../../../core/widgets/pf_empty_state.dart';
import '../../../../core/widgets/pf_error_state.dart';
import '../../../../core/widgets/pf_loading_indicator.dart';
import '../../../../core/widgets/pf_ranking_row.dart';
import '../../../../core/widgets/pf_segmented_control.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/ranking_entry.dart';
import '../bloc/ranking_cubit.dart';

const _margin = AppSpacing.roomy;

/// Avatar backgrounds, picked from the username so a player keeps theirs.
const _avatarColors = [
  AppColors.iridescent,
  AppColors.feather,
  AppColors.pin,
  AppColors.slate,
  AppColors.grain,
  AppColors.night,
];

// Not hashCode: it may differ between platforms and runs.
Color _avatarColor(String username) =>
    _avatarColors[username.codeUnits.fold(0, (a, b) => a + b) %
        _avatarColors.length];

String _initial(String username) =>
    username.isEmpty ? '?' : username.characters.first.toUpperCase();

/// Leaderboard around the user, of their country or the world: a podium for the
/// three best, the rest in a list, and the user's own row pinned at the
/// bottom.
class const RankingPage({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<RankingCubit>();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<RankingCubit, RankingState>(
          builder: (context, state) {
            final me = state.me;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    _margin,
                    AppSpacing.xl,
                    _margin,
                    AppSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            l10n.rankingTitle,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ),
                      ),
                      if (me != null)
                        PfAvatar(
                          initial: _initial(me.username),
                          backgroundColor: _avatarColor(me.username),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _margin),
                  child: PfSegmentedControl(
                    labels: [
                      for (final s in RankingScope.values)
                        state.labels?[s] ??
                            switch (s) {
                              RankingScope.nearby => l10n.rankingScopeNearby,
                              RankingScope.city => l10n.rankingScopeCity,
                              RankingScope.country => l10n.rankingScopeCountry,
                              RankingScope.world => l10n.rankingScopeWorld,
                            },
                    ],
                    selectedIndex: state.scope.index,
                    onChanged: (i) => cubit.setScope(RankingScope.values[i]),
                  ),
                ),
                Expanded(
                  child: switch (state.status) {
                    RankingStatus.loading => const Center(
                      child: PfLoadingIndicator(),
                    ),
                    RankingStatus.failure => Center(
                      child: PfErrorState(
                        message: l10n.rankingLoadError,
                        actionLabel: l10n.retry,
                        onAction: cubit.load,
                      ),
                    ),
                    RankingStatus.ready when state.entries.isEmpty => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(_margin),
                        child: PfEmptyState(
                          message: l10n.rankingEmpty,
                          icon: Icons.emoji_events_outlined,
                        ),
                      ),
                    ),
                    RankingStatus.ready => _Leaderboard(state: state),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class const _Leaderboard({required final RankingState state})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<RankingCubit>();
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final me = state.me;
    final others = state.others;
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            final messenger = ScaffoldMessenger.of(context);
            if (await cubit.load()) return;
            messenger.showSnackBar(
              SnackBar(content: Text(l10n.postErrorNetwork)),
            );
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              _margin,
              AppSpacing.xxxl,
              _margin,
              // Room for the pinned row and the floating bottom bar.
              bottomInset + (me != null ? 80 : _margin),
            ),
            children: [
              _Podium(entries: state.podium),
              if (others.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.cozy),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPanel),
                  ),
                  child: Column(
                    children: [
                      for (final (i, e) in others.indexed) ...[
                        if (i > 0)
                          const Divider(height: 1, color: AppColors.divider),
                        PfRankingRow(
                          rank: '${e.rank}',
                          avatarInitial: _initial(e.username),
                          avatarColor: _avatarColor(e.username),
                          title: e.username,
                          subtitle: l10n.mapPigeonCount(e.pigeons),
                          trailing: l10n.rankingPoints(e.score),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (me != null)
          Positioned(
            left: AppSpacing.cozy,
            right: AppSpacing.cozy,
            bottom: bottomInset + AppSpacing.sm,
            child: PfRankingRow(
              rank: '${me.rank}',
              avatarInitial: _initial(me.username),
              title: l10n.rankingMe,
              subtitle: switch ((me.nextScore, me.nextRank)) {
                (final score?, final rank?) => l10n.rankingToNext(
                  score - me.score + 1,
                  rank,
                ),
                _ => l10n.rankingLeader,
              },
              trailing: l10n.rankingPoints(me.score),
              highlighted: true,
            ),
          ),
      ],
    );
  }
}

/// The three best players on steps, second / first / third.
class const _Podium({required final List<RankingEntry> entries})
    extends StatelessWidget {
  /// Step height for ranks 1, 2 and 3.
  static const _stepHeights = [110.0, 84.0, 66.0];

  @override
  Widget build(BuildContext context) {
    final order = [if (entries.length > 1) 1, 0, if (entries.length > 2) 2];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final i in order)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.compact,
              ),
              child: _Step(
                entry: entries[i],
                height: _stepHeights[i],
                top: i == 0,
              ),
            ),
          ),
      ],
    );
  }
}

class const _Step({
  required final RankingEntry entry,
  required final double height,
  required final bool top,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final onStep = Theme.of(context).colorScheme.onSecondary;
    final avatarSize = top ? 72.0 : 58.0;
    return Semantics(
      label:
          '${entry.rank}, ${entry.username}, '
          '${l10n.rankingPoints(entry.score)}',
      excludeSemantics: true,
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.paper, width: AppSpacing.xs),
            ),
            child: PfAvatar(
              initial: _initial(entry.username),
              backgroundColor: _avatarColor(entry.username),
              size: avatarSize,
            ),
          ),
          const SizedBox(height: AppSpacing.compact),
          Text(
            entry.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge?.copyWith(fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.cozy),
          Container(
            height: height,
            width: double.infinity,
            padding: const EdgeInsets.only(top: AppSpacing.snug),
            decoration: BoxDecoration(
              color: AppColors.night,
              borderRadius: BorderRadius.circular(AppSpacing.cozy),
            ),
            child: Column(
              children: [
                Text(
                  '${entry.rank}',
                  style: textTheme.headlineLarge?.copyWith(color: onStep),
                ),
                Text(
                  l10n.rankingPoints(entry.score),
                  style: textTheme.labelMedium?.copyWith(color: onStep),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

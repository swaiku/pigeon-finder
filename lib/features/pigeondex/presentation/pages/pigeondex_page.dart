import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pf_chip.dart';
import '../../../../core/widgets/pf_empty_state.dart';
import '../../../../core/widgets/pf_error_state.dart';
import '../../../../core/widgets/pf_loading_indicator.dart';
import '../../../../core/widgets/pf_photo.dart';
import '../../../../core/widgets/pf_segmented_control.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../map/domain/entities/map_post.dart';
import '../../../post_detail/presentation/widgets/post_detail_sheet.dart';
import '../bloc/pigeondex_cubit.dart';

const _columns = 3;
const _gap = AppSpacing.sm;
const _margin = AppSpacing.lg;

/// Gallery of the user's own photos, grouped by month, city or points.
class const PigeondexPage({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<PigeondexCubit>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pigeondexTitle)),
      body: BlocBuilder<PigeondexCubit, PigeondexState>(
        builder: (context, state) => switch (state.status) {
          PigeondexStatus.loading => const Center(child: PfLoadingIndicator()),
          PigeondexStatus.failure => Center(
            child: PfErrorState(
              message: l10n.pigeondexLoadError,
              actionLabel: l10n.retry,
              onAction: cubit.load,
            ),
          ),
          PigeondexStatus.ready when state.posts.isEmpty => Center(
            child: Padding(
              padding: const EdgeInsets.all(_margin),
              child: PfEmptyState(
                message: l10n.pigeondexEmpty,
                icon: Icons.photo_camera_outlined,
              ),
            ),
          ),
          PigeondexStatus.ready => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(_margin, 0, _margin, _gap),
                child: PfSegmentedControl(
                  labels: [
                    l10n.pigeondexSortDate,
                    l10n.pigeondexSortPlace,
                    l10n.pigeondexSortTop,
                  ],
                  selectedIndex: state.sort.index,
                  onChanged: (i) => cubit.setSort(PigeondexSort.values[i]),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    if (await cubit.load()) return;
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.postErrorNetwork)),
                    );
                  },
                  child: _Gallery(sections: state.sections),
                ),
              ),
            ],
          ),
        },
      ),
    );
  }
}

class const _Gallery({required final List<PigeondexSection> sections})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tileWidth =
        (MediaQuery.sizeOf(context).width -
            2 * _margin -
            (_columns - 1) * _gap) /
        _columns;
    return CustomScrollView(
      // Lets a short gallery still be pulled to refresh.
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        for (final section in sections) ...[
          if (section.key case final key?)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(_margin, _gap, _margin, _gap),
              sliver: SliverToBoxAdapter(
                child: Semantics(
                  header: true,
                  child: Text(switch (key) {
                    DateTime() => toBeginningOfSentenceCase(
                      DateFormat.yMMMM(l10n.localeName).format(key),
                    ),
                    '' => l10n.pigeondexUnknownPlace,
                    _ => '$key',
                  }, style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(_margin, 0, _margin, _gap),
            sliver: SliverGrid.count(
              crossAxisCount: _columns,
              mainAxisSpacing: _gap,
              crossAxisSpacing: _gap,
              children: [
                for (final post in section.posts)
                  _Tile(key: ValueKey(post.id), post: post, width: tileWidth),
              ],
            ),
          ),
        ],
        // The page extends under the floating bottom bar.
        SliverPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom + _margin,
          ),
        ),
      ],
    );
  }
}

class const _Tile({
  super.key,
  required final MapPost post,
  required final double width,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final date = DateFormat.yMMMd(l10n.localeName)
        .format(post.createdAt.toLocal());
    // shortcut: the badge only updates on rebuild or refresh, add a timer
    // tick like MapBloc if it must drop off live
    final onMap = post.timeLeft() > Duration.zero;
    return Semantics(
      button: true,
      label: [
        if (post.place.isNotEmpty) post.place,
        date,
        if (onMap) l10n.pigeondexOnMap,
      ].join(', '),
      // excludeSemantics drops the detector's tap, so screen readers need it
      // here.
      onTap: () => showPostDetailSheet(context, post),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => showPostDetailSheet(context, post),
        child: PfPhoto(
          url: post.photoUrl,
          cacheWidth: width,
          child: onMap
              ? Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: PfStatusChip(
                        label: l10n.pigeondexOnMap,
                        tone: PfChipTone.success,
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

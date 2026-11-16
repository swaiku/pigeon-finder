import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:pigeon_finder/core/error/failures.dart';
import 'package:pigeon_finder/core/events/posts_changes.dart';
import 'package:pigeon_finder/core/widgets/pf_chip.dart';
import 'package:pigeon_finder/features/map/domain/entities/map_post.dart';
import 'package:pigeon_finder/features/map/domain/repositories/posts_repository.dart';
import 'package:pigeon_finder/features/pigeondex/presentation/bloc/pigeondex_cubit.dart';
import 'package:pigeon_finder/features/pigeondex/presentation/pages/pigeondex_page.dart';
import 'package:pigeon_finder/features/post_detail/presentation/widgets/post_detail_sheet.dart';
import 'package:pigeon_finder/l10n/app_localizations.dart';

MapPost _post(
  String id,
  DateTime createdAt, {
  String place = 'Lausanne',
  int points = 10,
  String? description,
}) => MapPost(
  description: description,
  id: id,
  user: 'grisou',
  place: place,
  photoUrl: 'https://signed/$id',
  position: const LatLng(46.52, 6.63),
  createdAt: createdAt,
  count: 1,
  points: points,
  coos: 0,
  mine: true,
);

/// Returns [posts], or throws [failure] when set.
class _FakePosts implements PostsRepository {
  _FakePosts(this.posts);

  List<MapPost> posts;
  Failure? failure;
  var calls = 0;

  @override
  Future<List<MapPost>> getMyPosts() async {
    calls++;
    if (failure case final f?) throw f;
    return posts;
  }

  @override
  Future<List<MapPost>> getActivePosts({required LatLng around}) async =>
      const [];
}

/// A cubit closed at the end of the test, which stops its refresh timer.
PigeondexCubit _cubit(PostsRepository posts, {PostsChanges? changes}) {
  final cubit = PigeondexCubit(posts: posts, changes: changes);
  addTearDown(cubit.close);
  return cubit;
}

List<List<String>> _ids(PigeondexState state) => [
  for (final section in state.sections) [for (final p in section.posts) p.id],
];

void main() {
  // Local times, as sections follow the user's calendar months.
  final nov2 = _post('nov2', DateTime(2026, 11, 12), points: 5);
  final nov1 = _post('nov1', DateTime(2026, 11, 2), place: 'Bern', points: 30);
  final oct = _post('oct', DateTime(2026, 10, 20), place: '', points: 30);
  final sep = _post(
    'sep',
    DateTime(2026, 9, 1),
    points: 20,
    description: 'On the roof',
  );
  final all = [nov2, nov1, oct, sep];

  test('load shows the posts, grouped by month by default', () async {
    final cubit = _cubit(_FakePosts(all));
    expect(cubit.state.status, PigeondexStatus.loading);

    await cubit.load();

    expect(cubit.state.status, PigeondexStatus.ready);
    expect(cubit.state.sections.map((s) => s.key), [
      DateTime(2026, 11),
      DateTime(2026, 10),
      DateTime(2026, 9),
    ]);
    expect(_ids(cubit.state), [
      ['nov2', 'nov1'],
      ['oct'],
      ['sep'],
    ]);
  });

  test('place sort puts the busiest city first and unknown last', () async {
    final cubit = _cubit(_FakePosts(all));
    await cubit.load();

    cubit.setSort(PigeondexSort.place);

    expect(cubit.state.sections.map((s) => s.key), ['Lausanne', 'Bern', '']);
    expect(_ids(cubit.state), [
      ['nov2', 'sep'],
      ['nov1'],
      ['oct'],
    ]);
  });

  test('top sort is one section by points, ties newest first', () async {
    final cubit = _cubit(_FakePosts(all));
    await cubit.load();

    cubit.setSort(PigeondexSort.top);

    expect(cubit.state.sections.single.key, isNull);
    expect(_ids(cubit.state), [
      ['nov1', 'oct', 'sep', 'nov2'],
    ]);
  });

  test('a failed first load ends in failure, and a retry recovers', () async {
    final repo = _FakePosts(all)..failure = const NetworkFailure('offline');
    final cubit = _cubit(repo);

    await cubit.load();
    expect(cubit.state.status, PigeondexStatus.failure);

    repo.failure = null;
    await cubit.load();
    expect(cubit.state.status, PigeondexStatus.ready);
    expect(cubit.state.posts, all);
  });

  test('a failed refresh keeps the photos already shown', () async {
    final repo = _FakePosts(all);
    final cubit = _cubit(repo);
    await cubit.load();

    repo.failure = const NetworkFailure('offline');
    await cubit.load();

    expect(cubit.state.status, PigeondexStatus.ready);
    expect(cubit.state.posts, all);
  });

  test('a new post elsewhere in the app reloads the gallery', () async {
    final repo = _FakePosts([sep]);
    final changes = PostsChanges();
    final cubit = _cubit(repo, changes: changes);
    await cubit.load();

    repo.posts = all;
    changes.notify();
    await pumpEventQueue();

    expect(repo.calls, 2);
    expect(cubit.state.posts, all);

    await changes.dispose();
  });

  testWidgets('the gallery shows month titles, the badge and opens a photo', (
    tester,
  ) async {
    final fresh = _post(
      'fresh',
      DateTime.now().subtract(const Duration(hours: 1)),
    );
    // Not `_cubit`: its tear-down close never completes in a widget test.
    final cubit = PigeondexCubit(posts: _FakePosts([fresh, sep]));
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // Not `.value`: the provider must close the cubit, and its refresh
        // timer, when the test's widget tree goes away.
        home: BlocProvider(create: (_) => cubit, child: const PigeondexPage()),
      ),
    );
    await cubit.load();
    await tester.pump();

    expect(find.text('September 2026'), findsOne);
    expect(find.text(DateFormat.yMMMM('en').format(fresh.createdAt)), findsOne);
    // Only the photo under 24 h old is still on the map.
    expect(find.byType(PfStatusChip), findsOne);

    // Screen readers get a button they can activate.
    final oldTile = find.bySemanticsLabel('Lausanne, Sep 1, 2026');
    expect(
      tester
          .getSemantics(oldTile)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );

    await tester.tap(oldTile);
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(PostDetailSheet), findsOne);
    // An old photo shows its date and no expiry countdown.
    expect(find.text('Lausanne · Sep 1, 2026'), findsOne);
    expect(find.textContaining('Expires in'), findsNothing);
    expect(find.text('On the roof'), findsOne);
  });
}

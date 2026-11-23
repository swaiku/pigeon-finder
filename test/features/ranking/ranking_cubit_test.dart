import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pigeon_finder/app.dart';
import 'package:pigeon_finder/core/error/failures.dart';
import 'package:pigeon_finder/core/events/posts_changes.dart';
import 'package:pigeon_finder/features/map/data/repositories/location_repository_impl.dart';
import 'package:pigeon_finder/features/map/data/repositories/region_repository_impl.dart';
import 'package:pigeon_finder/features/map/domain/repositories/location_repository.dart';
import 'package:pigeon_finder/features/ranking/data/repositories/supabase_ranking_repository.dart';
import 'package:pigeon_finder/features/ranking/domain/entities/ranking_entry.dart';
import 'package:pigeon_finder/features/ranking/presentation/bloc/ranking_cubit.dart';
import 'package:pigeon_finder/features/ranking/presentation/pages/ranking_page.dart';
import 'package:pigeon_finder/l10n/app_localizations.dart';

import '../../support/fake_location_data_source.dart';
import '../../support/fake_ranking_repository.dart';
import '../../support/fake_region_data_source.dart';

class _NoLocation implements LocationRepository {
  @override
  Future<LatLng> getUserPosition() =>
      Future.error(const PermissionFailure('denied'));

  @override
  Future<bool> requestPermission() async => false;

  @override
  Stream<LatLng> watchUserPosition() => const Stream.empty();
}

RankingEntry _entry(int rank, String name, int score, {bool me = false}) =>
    RankingEntry(
      rank: rank,
      username: name,
      score: score,
      pigeons: score ~/ 10,
      isMe: me,
    );

RankingCubit _cubit(
  FakeRankingRepository ranking, {
  LocationRepository? location,
  PostsChanges? changes,
}) {
  final cubit = RankingCubit(
    ranking: ranking,
    location:
        location ?? const LocationRepositoryImpl(FakeLocationDataSource()),
    regions: const RegionRepositoryImpl(FakeRegionDataSource()),
    changes: changes,
  );
  addTearDown(cubit.close);
  return cubit;
}

void main() {
  final paris = [
    _entry(1, 'biset_boss', 2140),
    _entry(2, 'roucoulette_75', 1990),
    _entry(3, 'plume.urbaine', 1655),
    _entry(4, 'grisou', 990, me: true),
  ];

  test('load opens around the user, with the place names as labels', () async {
    final ranking = FakeRankingRepository({RankingScope.nearby: paris});
    final cubit = _cubit(ranking);

    expect(await cubit.load(), isTrue);

    expect(ranking.calls, [
      (RankingScope.nearby, FakeLocationDataSource.position, 'FR'),
    ]);
    expect(cubit.state.status, RankingStatus.ready);
    expect(cubit.state.labels, {
      RankingScope.city: 'Paris',
      RankingScope.country: 'France',
    });
    expect(cubit.state.podium.map((e) => e.username), [
      'biset_boss',
      'roucoulette_75',
      'plume.urbaine',
    ]);
    expect(cubit.state.others.single.username, 'grisou');
    expect(cubit.state.me?.username, 'grisou');
  });

  test('without a position, lets the server use the latest post', () async {
    final ranking = FakeRankingRepository();
    final cubit = _cubit(ranking, location: _NoLocation());

    await cubit.load();

    expect(cubit.state.scope, RankingScope.nearby);
    expect(cubit.state.labels, isEmpty);
    expect(ranking.calls, [(RankingScope.nearby, null, null)]);
  });

  test('setScope loads the country by its ISO code', () async {
    final ranking = FakeRankingRepository({
      RankingScope.nearby: paris,
      RankingScope.country: [_entry(1, 'grisou', 990, me: true)],
    });
    final cubit = _cubit(ranking);
    await cubit.load();

    await cubit.setScope(RankingScope.country);

    expect(ranking.calls.last, (
      RankingScope.country,
      FakeLocationDataSource.position,
      'FR',
    ));
    expect(cubit.state.entries.single.rank, 1);
  });

  test(
    'a failed first load shows the error, a failed refresh keeps rows',
    () async {
      final ranking = FakeRankingRepository({RankingScope.nearby: paris})
        ..failure = const NetworkFailure('offline');
      final cubit = _cubit(ranking);

      expect(await cubit.load(), isFalse);
      expect(cubit.state.status, RankingStatus.failure);

      ranking.failure = null;
      await cubit.load();
      ranking.failure = const NetworkFailure('offline');
      expect(await cubit.load(), isFalse);
      expect(cubit.state.status, RankingStatus.ready);
      expect(cubit.state.entries, paris);
    },
  );

  test('reloads when a post is published', () async {
    final changes = PostsChanges();
    final ranking = FakeRankingRepository();
    final cubit = _cubit(ranking, changes: changes);
    await cubit.load();

    changes.notify();
    await Future<void>.delayed(Duration.zero);

    expect(ranking.calls, hasLength(2));
  });

  test('fromRow maps the leaderboard RPC row', () {
    final entry = SupabaseRankingRepository.fromRow({
      'rank': 9,
      'username': 'grisou',
      'score': 1240,
      'pigeons': 96,
      'me': true,
      'next_score': 1300,
      'next_rank': 8,
    });
    expect(
      entry,
      const RankingEntry(
        rank: 9,
        username: 'grisou',
        score: 1240,
        pigeons: 96,
        isMe: true,
        nextScore: 1300,
        nextRank: 8,
      ),
    );
  });

  testWidgets('the page shows the podium, the list and the user\'s gap', (
    tester,
  ) async {
    final cubit = RankingCubit(
      ranking: FakeRankingRepository({
        RankingScope.nearby: [
          ...paris.take(3),
          _entry(4, 'le_pigeonnier', 1180),
          const RankingEntry(
            rank: 5,
            username: 'grisou',
            score: 990,
            pigeons: 141,
            isMe: true,
            nextScore: 1180,
            nextRank: 4,
          ),
        ],
      }),
      location: const LocationRepositoryImpl(FakeLocationDataSource()),
      regions: const RegionRepositoryImpl(FakeRegionDataSource()),
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: PigeonFinderApp.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider(create: (_) => cubit, child: const RankingPage()),
      ),
    );
    await tester.runAsync(cubit.load);
    await tester.pump();

    expect(find.text('Nearby'), findsOne);
    expect(find.text('Paris'), findsOne);
    expect(find.text('France'), findsOne);
    expect(find.text('World'), findsOne);
    expect(find.text('biset_boss'), findsOne);
    expect(find.text('2,140 pts'), findsOne);
    expect(find.text('le_pigeonnier'), findsOne);
    expect(find.text('You'), findsOne);
    expect(find.text('191 pts to pass #4'), findsOne);
  });
}

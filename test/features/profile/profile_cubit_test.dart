import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pigeon_finder/app.dart';
import 'package:pigeon_finder/core/error/failures.dart';
import 'package:pigeon_finder/core/events/posts_changes.dart';
import 'package:pigeon_finder/core/widgets/pf_button.dart';
import 'package:pigeon_finder/features/map/domain/entities/map_post.dart';
import 'package:pigeon_finder/features/map/domain/repositories/posts_repository.dart';
import 'package:pigeon_finder/features/profile/domain/entities/level.dart';
import 'package:pigeon_finder/features/profile/domain/entities/profile.dart';
import 'package:pigeon_finder/features/profile/domain/entities/profile_badge.dart';
import 'package:pigeon_finder/features/profile/domain/repositories/profile_repository.dart';
import 'package:pigeon_finder/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:pigeon_finder/features/profile/presentation/pages/profile_page.dart';
import 'package:pigeon_finder/l10n/app_localizations.dart';

MapPost _post(
  String id,
  DateTime createdAt, {
  String place = 'Lausanne',
  int count = 1,
  int coos = 0,
}) => MapPost(
  id: id,
  user: 'grisou',
  place: place,
  photoUrl: 'https://signed/$id',
  position: const LatLng(46.52, 6.63),
  createdAt: createdAt,
  count: count,
  points: count * 10,
  coos: coos,
  mine: true,
);

/// Returns [posts], or throws [failure] when set.
class _FakePosts implements PostsRepository {
  _FakePosts(this.posts);

  List<MapPost> posts;
  Failure? failure;

  @override
  Future<List<MapPost>> getMyPosts() async {
    if (failure case final f?) throw f;
    return posts;
  }

  @override
  Future<List<MapPost>> getActivePosts({required LatLng around}) async =>
      const [];
}

/// Returns [profile], or throws [failure] when set.
class _FakeProfile implements ProfileRepository {
  Profile profile = const Profile(username: 'grisou');
  Failure? failure;
  final uploaded = <String>[];

  @override
  Future<Profile> getProfile() async {
    if (failure case final f?) throw f;
    return profile;
  }

  @override
  Future<String> setAvatar(File photo) async {
    if (failure case final f?) throw f;
    uploaded.add(photo.path);
    return 'https://signed/avatar';
  }
}

/// A cubit closed at the end of the test, which stops its refresh timer.
ProfileCubit _cubit(
  ProfileRepository profile,
  PostsRepository posts, {
  PostsChanges? changes,
}) {
  final cubit = ProfileCubit(profile: profile, posts: posts, changes: changes);
  addTearDown(cubit.close);
  return cubit;
}

void main() {
  group('Level', () {
    test('is picked from the XP thresholds', () {
      expect(Level.of(0), Level.fledgling);
      expect(Level.of(49), Level.fledgling);
      expect(Level.of(50), Level.forager);
      expect(Level.of(99999), Level.rooftopKing);
    });

    test('progress runs from one threshold to the next', () {
      expect(Level.forager.progress(100), .5);
      expect(Level.rooftopKing.next, isNull);
      expect(Level.rooftopKing.progress(99999), 1);
    });
  });

  group('ProfileState', () {
    // Local times: the streak follows the user's calendar days.
    final now = DateTime(2026, 11, 23, 15);

    test('XP counts photos, active days and coos given', () {
      final state = ProfileState(
        profile: const Profile(username: 'grisou', likesGiven: 3),
        posts: [
          _post('a', DateTime(2026, 11, 23, 9)),
          _post('b', DateTime(2026, 11, 23, 8)),
          _post('c', DateTime(2026, 11, 20, 8)),
        ],
      );
      // 3 photos, 2 days, 3 coos.
      expect(state.xp, 3 * 20 + 2 * 10 + 3 * 2);
      expect(state.level, Level.forager);
    });

    test('a streak with a photo today ends after tomorrow', () {
      final state = ProfileState(
        posts: [
          _post('today', DateTime(2026, 11, 23, 9)),
          _post('yesterday', DateTime(2026, 11, 22, 22)),
          _post('before', DateTime(2026, 11, 21, 1)),
          _post('gap', DateTime(2026, 11, 19, 12)),
        ],
      );
      expect(state.streak(now: now), (
        days: 3,
        expiresAt: DateTime(2026, 11, 25),
      ));
    });

    test('a streak last fed yesterday ends tonight', () {
      final state = ProfileState(
        posts: [
          _post('yesterday', DateTime(2026, 11, 22, 9)),
          _post('before', DateTime(2026, 11, 21, 9)),
        ],
      );
      expect(state.streak(now: now), (
        days: 2,
        expiresAt: DateTime(2026, 11, 24),
      ));
    });

    test('a missed day breaks the streak', () {
      final state = ProfileState(
        posts: [_post('old', DateTime(2026, 11, 21, 9))],
      );
      expect(state.streak(now: now), (days: 0, expiresAt: null));
      expect(const ProfileState().streak(now: now).days, 0);
    });

    test('badges follow photos, coos and pigeon counts', () {
      final posts = [
        for (var i = 0; i < 10; i++)
          _post('p$i', DateTime(2026, 11, 1 + i, 12), coos: 3),
      ];
      expect(
        ProfileState(
          profile: const Profile(username: 'grisou', likesGiven: 25),
          posts: posts,
        ).badges,
        {ProfileBadge.photographer, ProfileBadge.fan, ProfileBadge.star},
      );
      expect(
        ProfileState(
          posts: [
            _post('flock', DateTime(2026, 11, 1, 12), count: 10),
            _post('dawn', DateTime(2026, 11, 2, 6, 59)),
          ],
        ).badges,
        {ProfileBadge.flock, ProfileBadge.earlyBird},
      );
    });

    test('only photos under 24 h old are on the map', () {
      final state = ProfileState(
        posts: [
          _post('fresh', now.subtract(const Duration(hours: 2))),
          _post('old', now.subtract(const Duration(hours: 25))),
        ],
      );
      expect(state.onMap(now: now).map((p) => p.id), ['fresh']);
      expect(state.lastPlace, 'Lausanne');
    });
  });

  group('ProfileCubit', () {
    test('load shows the profile and posts', () async {
      final posts = [_post('a', DateTime(2026, 11, 23))];
      final cubit = _cubit(_FakeProfile(), _FakePosts(posts));

      expect(await cubit.load(), isTrue);

      expect(cubit.state.status, ProfileStatus.ready);
      expect(cubit.state.profile?.username, 'grisou');
      expect(cubit.state.posts, posts);
    });

    test('a failed first load ends in failure, a failed refresh keeps the '
        'profile', () async {
      final profile = _FakeProfile()..failure = const NetworkFailure('offline');
      final cubit = _cubit(profile, _FakePosts(const []));

      expect(await cubit.load(), isFalse);
      expect(cubit.state.status, ProfileStatus.failure);

      profile.failure = null;
      await cubit.load();
      profile.failure = const NetworkFailure('offline');
      expect(await cubit.load(), isFalse);
      expect(cubit.state.status, ProfileStatus.ready);
    });

    test('a new post elsewhere in the app reloads the profile', () async {
      final repo = _FakePosts(const []);
      final changes = PostsChanges();
      final cubit = _cubit(_FakeProfile(), repo, changes: changes);
      await cubit.load();

      repo.posts = [_post('new', DateTime(2026, 11, 23))];
      changes.notify();
      await pumpEventQueue();

      expect(cubit.state.posts, repo.posts);
      await changes.dispose();
    });

    test('changeAvatar shows the new photo, and reports a failure', () async {
      final profile = _FakeProfile();
      final cubit = _cubit(profile, _FakePosts(const []));
      await cubit.load();

      expect(await cubit.changeAvatar(File('/tmp/me.jpg')), isTrue);
      expect(cubit.state.profile?.avatarUrl, 'https://signed/avatar');
      expect(cubit.state.uploadingAvatar, isFalse);
      expect(profile.uploaded, ['/tmp/me.jpg']);

      profile.failure = const ServerFailure('denied');
      expect(await cubit.changeAvatar(File('/tmp/other.jpg')), isFalse);
      expect(cubit.state.profile?.avatarUrl, 'https://signed/avatar');
      expect(cubit.state.uploadingAvatar, isFalse);
    });
  });

  testWidgets('the page shows the level, stats and badges, and the avatar '
      'opens the photo dialog', (tester) async {
    final fresh = _post(
      'fresh',
      DateTime.now().subtract(const Duration(hours: 1)),
      place: 'Paris',
      count: 3,
    );
    // Not `_cubit`: its tear-down close never completes in a widget test.
    final cubit = ProfileCubit(
      profile: _FakeProfile(),
      posts: _FakePosts([fresh]),
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: PigeonFinderApp.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // Not `.value`: the provider must close the cubit, and its refresh
        // timer, when the test's widget tree goes away.
        home: BlocProvider(create: (_) => cubit, child: const ProfilePage()),
      ),
    );
    await cubit.load();
    await tester.pump();

    expect(find.text('grisou'), findsOne);
    // 1 photo + 1 active day = 30 XP.
    expect(find.text('Squab · lvl 1'), findsOne);
    expect(find.text('30 / 50'), findsOne);
    expect(find.text('Next level: Crumb Hunter'), findsOne);
    expect(find.text('1 d'), findsOne);
    expect(find.text('On the map right now'), findsOne);
    expect(find.text('3 pigeons · expires in 23 h'), findsOne);
    expect(find.text('Photographer · 10 photos'), findsOne);

    await tester.tap(find.bySemanticsLabel('Profile photo'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(PfButton, 'Change profile pic'), findsOne);
  });
}

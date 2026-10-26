import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:pigeon_finder/core/error/failures.dart';
import 'package:pigeon_finder/features/map/data/datasources/location_data_source.dart';
import 'package:pigeon_finder/features/map/data/datasources/region_data_source.dart';
import 'package:pigeon_finder/features/map/data/repositories/fake_posts_repository.dart';
import 'package:pigeon_finder/features/map/domain/entities/map_post.dart';
import 'package:pigeon_finder/features/map/domain/entities/region_level.dart';
import 'package:pigeon_finder/features/map/domain/repositories/posts_repository.dart';
import 'package:pigeon_finder/features/map/presentation/bloc/map_bloc.dart';

import '../../support/test_map_bloc.dart';

class _FailingPosts implements PostsRepository {
  @override
  Future<List<MapPost>> getActivePosts({required LatLng around}) async =>
      throw const NetworkFailure('offline');
}

class _FailingRegions implements RegionDataSource {
  const _FailingRegions();

  @override
  Future<String> getRegionName(LatLng position, RegionLevel level) async =>
      throw const NetworkFailure('throttled');
}

final _bounds = LatLngBounds(const LatLng(46.5, 6.6), const LatLng(46.6, 6.7));

void main() {
  blocTest<MapBloc, MapState>(
    'MapStarted loads posts and user position',
    build: testMapBloc,
    act: (bloc) => bloc.add(const MapStarted()),
    verify: (bloc) {
      expect(bloc.state.status, MapStatus.success);
      expect(bloc.state.posts, isNotEmpty);
      expect(bloc.state.userPosition, isNotNull);
    },
  );

  blocTest<MapBloc, MapState>(
    'MapStarted emits failure when the repository throws',
    build: () => testMapBloc(posts: _FailingPosts()),
    act: (bloc) => bloc.add(const MapStarted()),
    verify: (bloc) {
      expect(bloc.state.status, MapStatus.failure);
      expect(bloc.state.errorMessage, 'offline');
    },
  );

  late String selectedId;

  blocTest<MapBloc, MapState>(
    'MapPostSelected selects then clears a post',
    build: testMapBloc,
    act: (bloc) async {
      bloc.add(const MapStarted());
      await Future<void>.delayed(Duration.zero);
      selectedId = bloc.state.posts.first.id;
      bloc.add(MapPostSelected(selectedId));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.selected?.id, selectedId);
      bloc.add(const MapPostSelected(null));
    },
    verify: (bloc) => expect(bloc.state.selected, isNull),
  );

  blocTest<MapBloc, MapState>(
    'MapCameraMoved updates the region name',
    build: testMapBloc,
    act: (bloc) async {
      bloc.add(MapCameraMoved(const LatLng(46.52, 6.63), 14, _bounds));
      await Future<void>.delayed(const Duration(milliseconds: 600));
    },
    verify: (bloc) => expect(bloc.state.regionName, 'Lausanne'),
  );

  blocTest<MapBloc, MapState>(
    'zooming out widens the region name',
    build: testMapBloc,
    act: (bloc) async {
      bloc.add(MapCameraMoved(const LatLng(46.52, 6.63), 10, _bounds));
      await Future<void>.delayed(const Duration(milliseconds: 600));
    },
    verify: (bloc) {
      expect(bloc.state.regionLevel, RegionLevel.region);
      expect(bloc.state.regionName, 'Vaud');
    },
  );

  test('RegionLevel follows the zoom', () {
    expect(RegionLevel.fromZoom(14), RegionLevel.city);
    expect(RegionLevel.fromZoom(12), RegionLevel.city);
    expect(RegionLevel.fromZoom(11.9), RegionLevel.region);
    expect(RegionLevel.fromZoom(8), RegionLevel.region);
    expect(RegionLevel.fromZoom(7.9), RegionLevel.country);
    expect(RegionLevel.fromZoom(4), RegionLevel.country);
  });

  blocTest<MapBloc, MapState>(
    'MapStarted still loads the posts when the location is denied',
    build: () => testMapBloc(location: const _DeniedLocation()),
    act: (bloc) => bloc.add(const MapStarted()),
    verify: (bloc) {
      expect(bloc.state.status, MapStatus.success);
      expect(bloc.state.posts, isNotEmpty);
      expect(bloc.state.userPosition, isNull);
    },
  );

  blocTest<MapBloc, MapState>(
    'walking far away swaps the posts around the user',
    build: () => testMapBloc(location: const _WalkingLocation()),
    act: (bloc) async {
      bloc.add(const MapStarted());
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    },
    verify: (bloc) {
      expect(bloc.state.userPosition, _WalkingLocation.end);
      expect(bloc.state.posts, isNotEmpty);
      // Everything left behind is gone: all posts are near the new position.
      for (final p in bloc.state.posts) {
        expect(
          const Distance()(p.position, _WalkingLocation.end),
          lessThan(3000),
        );
      }
    },
  );

  blocTest<MapBloc, MapState>(
    'the map keeps working when the region name cannot be resolved',
    build: () => testMapBloc(regions: const _FailingRegions()),
    act: (bloc) => bloc.add(const MapStarted()),
    verify: (bloc) {
      expect(bloc.state.status, MapStatus.success);
      expect(bloc.state.regionName, isNull);
    },
  );

  blocTest<MapBloc, MapState>(
    'a successful retry clears the error message',
    build: () => testMapBloc(posts: _FlakyPosts()),
    act: (bloc) async {
      bloc.add(const MapStarted());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.errorMessage, 'offline');
      bloc.add(const MapStarted());
    },
    verify: (bloc) {
      expect(bloc.state.status, MapStatus.success);
      expect(bloc.state.errorMessage, isNull);
    },
  );

  blocTest<MapBloc, MapState>(
    'the clock drops the posts that expired',
    build: testMapBloc,
    act: (bloc) async {
      bloc.add(const MapStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(MapClockTicked(DateTime.now().add(MapPost.lifetime * 2)));
    },
    verify: (bloc) {
      expect(bloc.state.posts, isNotEmpty);
      expect(bloc.state.activePosts, isEmpty);
      expect(bloc.state.pigeonsInView, 0);
    },
  );

  blocTest<MapBloc, MapState>(
    'pigeonsInView only counts the posts on screen',
    build: testMapBloc,
    act: (bloc) async {
      bloc.add(const MapStarted());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.pigeonsInView, greaterThan(0));
      // Looks at an empty corner of the world.
      bloc.add(
        MapCameraMoved(
          const LatLng(0, 0),
          14,
          LatLngBounds(const LatLng(-1, -1), const LatLng(1, 1)),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 600));
    },
    verify: (bloc) {
      expect(bloc.state.pigeonsInView, 0);
      expect(bloc.state.userInView, isFalse);
    },
  );

  blocTest<MapBloc, MapState>(
    'MapUserPositionChanged updates the user position',
    build: testMapBloc,
    act: (bloc) => bloc.add(const MapUserPositionChanged(LatLng(1, 2))),
    verify: (bloc) => expect(bloc.state.userPosition, const LatLng(1, 2)),
  );
}

class _FlakyPosts implements PostsRepository {
  final _real = FakePostsRepository();
  var _calls = 0;

  @override
  Future<List<MapPost>> getActivePosts({required LatLng around}) async {
    if (_calls++ == 0) throw const NetworkFailure('offline');
    return _real.getActivePosts(around: around);
  }
}

class _WalkingLocation implements LocationDataSource {
  const _WalkingLocation();

  static const start = LatLng(48.8650, 2.3780);
  // About 5 km east of the start.
  static const end = LatLng(48.8650, 2.4480);

  @override
  Future<LatLng> getCurrentPosition() async => start;

  @override
  Stream<LatLng> watchPosition() => Stream.value(end);
}

class _DeniedLocation implements LocationDataSource {
  const _DeniedLocation();

  @override
  Future<LatLng> getCurrentPosition() async =>
      throw const PermissionFailure('denied');

  @override
  Stream<LatLng> watchPosition() => const Stream.empty();
}

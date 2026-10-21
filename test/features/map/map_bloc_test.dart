import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:pigeon_finder/core/error/failures.dart';
import 'package:pigeon_finder/features/map/data/datasources/location_data_source.dart';
import 'package:pigeon_finder/features/map/domain/entities/map_post.dart';
import 'package:pigeon_finder/features/map/domain/entities/region_level.dart';
import 'package:pigeon_finder/features/map/domain/repositories/map_repository.dart';
import 'package:pigeon_finder/features/map/presentation/bloc/map_bloc.dart';

import '../../support/test_map_repository.dart';

class _FailingRepository implements MapRepository {
  @override
  Future<List<MapPost>> getActivePosts({required LatLng around}) async =>
      throw const NetworkFailure('offline');

  @override
  Future<LatLng> getUserPosition() async => const LatLng(0, 0);

  @override
  Stream<LatLng> watchUserPosition() => const Stream.empty();

  @override
  Future<String> getRegionName(LatLng position, RegionLevel level) async => '';
}

void main() {
  blocTest<MapBloc, MapState>(
    'MapStarted loads posts and user position',
    build: () => MapBloc(testMapRepository()),
    act: (bloc) => bloc.add(const MapStarted()),
    verify: (bloc) {
      expect(bloc.state.status, MapStatus.success);
      expect(bloc.state.posts, isNotEmpty);
      expect(bloc.state.userPosition, isNotNull);
    },
  );

  blocTest<MapBloc, MapState>(
    'MapStarted emits failure when the repository throws',
    build: () => MapBloc(_FailingRepository()),
    act: (bloc) => bloc.add(const MapStarted()),
    verify: (bloc) {
      expect(bloc.state.status, MapStatus.failure);
      expect(bloc.state.errorMessage, 'offline');
    },
  );

  late String selectedId;

  blocTest<MapBloc, MapState>(
    'MapPostSelected selects then clears a post',
    build: () => MapBloc(testMapRepository()),
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
    build: () => MapBloc(testMapRepository()),
    act: (bloc) async {
      bloc.add(const MapCameraMoved(LatLng(46.52, 6.63), 14));
      await Future<void>.delayed(const Duration(milliseconds: 600));
    },
    verify: (bloc) => expect(bloc.state.regionName, 'Lausanne'),
  );

  blocTest<MapBloc, MapState>(
    'zooming out widens the region name',
    build: () => MapBloc(testMapRepository()),
    act: (bloc) async {
      bloc.add(const MapCameraMoved(LatLng(46.52, 6.63), 10));
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
    build: () => MapBloc(testMapRepository(location: _DeniedLocation())),
    act: (bloc) => bloc.add(const MapStarted()),
    verify: (bloc) {
      expect(bloc.state.status, MapStatus.success);
      expect(bloc.state.posts, isNotEmpty);
      expect(bloc.state.userPosition, isNull);
    },
  );

  blocTest<MapBloc, MapState>(
    'walking far away swaps the posts around the user',
    build: () => MapBloc(testMapRepository(location: const _WalkingLocation())),
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
    'MapUserPositionChanged updates the user position',
    build: () => MapBloc(testMapRepository()),
    act: (bloc) => bloc.add(const MapUserPositionChanged(LatLng(1, 2))),
    verify: (bloc) => expect(bloc.state.userPosition, const LatLng(1, 2)),
  );
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

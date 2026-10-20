import 'dart:math' as math;

import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/map_post.dart';
import '../../domain/entities/region_level.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/location_data_source.dart';
import '../datasources/region_data_source.dart';

/// In-memory stand-in for the Supabase-backed repository. Posts are made up
/// around the requested position: the world is cut into small cells, each one
/// seeded by its coordinates, so a given spot always holds the same posts.
/// Walking away drops the posts left behind and reveals the ones ahead.
/// Swap it in `injection.dart` once the real data sources exist.
class FakeMapRepository implements MapRepository {
  FakeMapRepository({required this.regions, required this.location});

  final RegionDataSource regions;
  final LocationDataSource location;

  /// Size of a cell, in degrees (about 550 m of latitude).
  static const _cellSize = 0.005;

  /// Cells generated on each side of the one containing the user.
  static const _radiusInCells = 3;

  static const _users = [
    'roucoulette_75',
    'biset_boss',
    'Mamie Graines',
    'le_pigeonnier',
    'grisou',
    'plume.urbaine',
    'coo_coo_cat',
    'Pigeon Vole',
  ];

  static const _places = [
    'Place du marché',
    'Parvis de la gare',
    'Square',
    'Pont',
    'Fontaine',
    'Terrasse de café',
    'Parc',
    'Statue',
  ];

  static const _uuid = Uuid();

  final _cells = <(int, int), List<MapPost>>{};

  List<MapPost> _generateCell(int cx, int cy) {
    final rng = math.Random(cx * 73856093 ^ cy * 19349663);
    // About one cell in three holds a post, a few hold two.
    final n = rng.nextInt(3) == 0 ? 1 + rng.nextInt(2) : 0;
    final now = DateTime.now();
    return [
      for (var i = 0; i < n; i++)
        () {
          final count = 1 + rng.nextInt(8);
          return MapPost(
            id: _uuid.v4(),
            user: _users[rng.nextInt(_users.length)],
            place: _places[rng.nextInt(_places.length)],
            position: LatLng(
              (cy + rng.nextDouble()) * _cellSize,
              (cx + rng.nextDouble()) * _cellSize,
            ),
            createdAt: now.subtract(Duration(minutes: rng.nextInt(24 * 60))),
            count: count,
            points: count * 7,
            coos: rng.nextInt(60),
            reports: rng.nextInt(10) == 0 ? 1 + rng.nextInt(2) : 0,
          );
        }(),
    ];
  }

  @override
  Future<List<MapPost>> getActivePosts({required LatLng around}) async {
    final cx = (around.longitude / _cellSize).floor();
    final cy = (around.latitude / _cellSize).floor();
    final now = DateTime.now();
    return [
      for (var dy = -_radiusInCells; dy <= _radiusInCells; dy++)
        for (var dx = -_radiusInCells; dx <= _radiusInCells; dx++)
          ..._cells
              .putIfAbsent((
                cx + dx,
                cy + dy,
              ), () => _generateCell(cx + dx, cy + dy))
              .where((p) => p.timeLeft(now: now) > Duration.zero),
    ];
  }

  @override
  Future<LatLng> getUserPosition() => location.getCurrentPosition();

  @override
  Stream<LatLng> watchUserPosition() => location.watchPosition();

  @override
  Future<String> getRegionName(LatLng position, RegionLevel level) =>
      regions.getRegionName(position, level);
}

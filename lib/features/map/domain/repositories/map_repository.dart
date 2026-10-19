import 'package:latlong2/latlong.dart';

import '../entities/map_post.dart';
import '../entities/region_level.dart';

/// Source of the data shown on the map. Implementations throw a `Failure`
/// (see core/error/failures.dart) when the data cannot be loaded.
abstract interface class MapRepository {
  /// Photos (less than 24 h old) in the surroundings of [around].
  Future<List<MapPost>> getActivePosts({required LatLng around});

  /// Where the user currently is.
  Future<LatLng> getUserPosition();

  /// Positions of the user as they move, after [getUserPosition].
  Stream<LatLng> watchUserPosition();

  /// Name of the zone containing [position], at the given [level].
  Future<String> getRegionName(LatLng position, RegionLevel level);
}

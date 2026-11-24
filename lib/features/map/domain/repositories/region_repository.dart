import 'package:latlong2/latlong.dart';

import '../entities/region_level.dart';

/// Names the zones of the map. Implementations throw a `Failure` when the
/// name cannot be resolved.
abstract interface class RegionRepository {
  /// Name of the zone containing [position], at the given [level].
  Future<String> getRegionName(LatLng position, RegionLevel level);

  /// ISO 3166-1 alpha-2 code of the country containing [position] ("CH").
  Future<String> getCountryCode(LatLng position);
}

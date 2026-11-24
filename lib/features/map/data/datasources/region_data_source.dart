import 'package:latlong2/latlong.dart';

import '../../domain/entities/region_level.dart';

/// Resolves a coordinate to a human-readable zone name.
abstract interface class RegionDataSource {
  Future<String> getRegionName(LatLng position, RegionLevel level);

  /// ISO 3166-1 alpha-2 code of the country containing [position] ("CH"),
  /// the same whatever the phone's language, unlike the names.
  Future<String> getCountryCode(LatLng position);
}

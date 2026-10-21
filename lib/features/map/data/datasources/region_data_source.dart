import 'package:latlong2/latlong.dart';

import '../../domain/entities/region_level.dart';

/// Resolves a coordinate to a human-readable zone name.
abstract interface class RegionDataSource {
  Future<String> getRegionName(LatLng position, RegionLevel level);
}

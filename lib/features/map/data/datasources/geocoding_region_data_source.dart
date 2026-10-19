import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/region_level.dart';
import 'region_data_source.dart';

/// Reverse geocoding through the platform geocoder (Android `Geocoder`,
/// iOS `CLGeocoder`). Neither publishes a hard quota, but both throttle apps
/// that call them too often (Apple documents roughly 50 requests per minute),
/// so results are cached per ~1 km cell to keep the call count low.
class GeocodingRegionDataSource implements RegionDataSource {
  GeocodingRegionDataSource({Geocoding? geocoding})
    : _geocoding = geocoding ?? Geocoding();

  final Geocoding _geocoding;
  final _cache = <(int, int), List<Placemark>>{};

  /// Cell size of the cache, in degrees (~1.1 km of latitude).
  static const _cellDegrees = 0.01;

  @override
  Future<String> getRegionName(LatLng position, RegionLevel level) async {
    final placemarks = await _placemarks(position);
    for (final p in placemarks) {
      // Falls back to wider zones when the requested one is missing.
      final names = switch (level) {
        RegionLevel.city => [
          p.locality,
          p.subAdministrativeArea,
          p.administrativeArea,
          p.country,
        ],
        RegionLevel.region => [p.administrativeArea, p.country],
        RegionLevel.country => [p.country],
      };
      final name = names.firstWhere(
        (n) => n != null && n.isNotEmpty,
        orElse: () => null,
      );
      if (name != null) return name;
    }
    throw const LocationFailure('No region name for this position');
  }

  Future<List<Placemark>> _placemarks(LatLng position) async {
    final key = (
      (position.latitude / _cellDegrees).round(),
      (position.longitude / _cellDegrees).round(),
    );
    final cached = _cache[key];
    if (cached != null) return cached;
    try {
      return _cache[key] = await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
    } on Exception catch (e) {
      // Also covers throttling and offline errors reported by the platform.
      throw NetworkFailure('Reverse geocoding failed: $e');
    }
  }
}

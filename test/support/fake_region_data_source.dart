import 'package:latlong2/latlong.dart';

import 'package:pigeon_finder/features/map/data/datasources/region_data_source.dart';
import 'package:pigeon_finder/features/map/domain/entities/region_level.dart';

/// Offline stand-in (tests only) for reverse geocoding: nearest of a few known cities.
class FakeRegionDataSource implements RegionDataSource {
  const FakeRegionDataSource();

  // city -> (center, region, country)
  static const _cities = <String, (LatLng, String, String)>{
    'Paris': (LatLng(48.8566, 2.3522), 'Île-de-France', 'France'),
    'Lyon': (LatLng(45.7640, 4.8357), 'Auvergne-Rhône-Alpes', 'France'),
    'Marseille': (
      LatLng(43.2965, 5.3698),
      'Provence-Alpes-Côte d\'Azur',
      'France',
    ),
    'Bruxelles': (
      LatLng(50.8503, 4.3517),
      'Région de Bruxelles-Capitale',
      'Belgique',
    ),
    'Genève': (LatLng(46.2044, 6.1432), 'Genève', 'Suisse'),
    'Lausanne': (LatLng(46.5197, 6.6323), 'Vaud', 'Suisse'),
    'Londres': (LatLng(51.5072, -0.1276), 'Angleterre', 'Royaume-Uni'),
  };

  @override
  Future<String> getRegionName(LatLng position, RegionLevel level) async {
    const distance = Distance();
    final nearest = _cities.entries.reduce(
      (a, b) => distance(position, a.value.$1) <= distance(position, b.value.$1)
          ? a
          : b,
    );
    final (_, region, country) = nearest.value;
    return switch (level) {
      RegionLevel.city => nearest.key,
      RegionLevel.region => region,
      RegionLevel.country => country,
    };
  }
}

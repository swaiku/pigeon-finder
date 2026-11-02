import 'package:latlong2/latlong.dart';

import 'package:pigeon_finder/features/map/data/datasources/location_data_source.dart';

/// Fixed position (Paris, Oberkampf) for tests.
class FakeLocationDataSource implements LocationDataSource {
  const FakeLocationDataSource();

  static const position = LatLng(48.8650, 2.3780);

  @override
  Future<LatLng> getCurrentPosition() async => position;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Stream<LatLng> watchPosition() => const Stream.empty();
}

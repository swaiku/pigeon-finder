import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/error/failures.dart';
import 'location_data_source.dart';

/// Device position through the `geolocator` plugin.
class const GeolocatorLocationDataSource() implements LocationDataSource {
  /// Minimum distance (in meters) before the stream emits again.
  static const _distanceFilter = 10;

  static const _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: _distanceFilter,
  );

  /// Without a fix (emulator with no mocked location, indoor GPS) the platform
  /// never answers, so give up and let the caller fall back.
  static const _fixTimeout = Duration(seconds: 5);

  @override
  Future<LatLng> getCurrentPosition() async {
    await _ensureAccess();
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: _fixTimeout,
        ),
      );
      return LatLng(p.latitude, p.longitude);
    } on Exception catch (e) {
      throw LocationFailure('Could not read the position: $e');
    }
  }

  @override
  Stream<LatLng> watchPosition() async* {
    await _ensureAccess();
    yield* Geolocator.getPositionStream(locationSettings: _settings)
        .map((p) => LatLng(p.latitude, p.longitude));
  }

  Future<void> _ensureAccess() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationFailure('Location services are disabled');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const PermissionFailure('Location permission denied');
    }
  }
}

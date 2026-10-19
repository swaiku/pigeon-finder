import 'package:latlong2/latlong.dart';

/// Source of the device position. Implementations throw a
/// `PermissionFailure` or `LocationFailure` when it is unavailable.
abstract interface class LocationDataSource {
  Future<LatLng> getCurrentPosition();

  /// Emits a new position each time the user moved significantly.
  Stream<LatLng> watchPosition();
}

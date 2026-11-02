import 'package:latlong2/latlong.dart';

/// Source of the device position. Implementations throw a
/// `PermissionFailure` or `LocationFailure` when it is unavailable.
abstract interface class LocationDataSource {
  Future<LatLng> getCurrentPosition();

  /// Whether the permission is granted, asking for it if not answered yet.
  Future<bool> requestPermission();

  /// Emits a new position each time the user moved significantly.
  Stream<LatLng> watchPosition();
}

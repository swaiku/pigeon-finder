import 'package:latlong2/latlong.dart';

/// Where the user is. Implementations throw a `PermissionFailure` or a
/// `LocationFailure` when the position is unavailable.
abstract interface class LocationRepository {
  /// Where the user currently is.
  Future<LatLng> getUserPosition();

  /// Asks the user for the permission, unless already answered. Whether it is
  /// granted.
  Future<bool> requestPermission();

  /// Positions of the user as they move, after [getUserPosition].
  Stream<LatLng> watchUserPosition();
}

import 'package:latlong2/latlong.dart';

/// Where the map is centered while the user position is unknown.
const defaultMapCenter = LatLng(48.8625, 2.3550);

/// Zoom the map opens at.
const defaultMapZoom = 14.0;

/// How close to a spot the user must be to post there, in meters. Only drawn
/// on the map for now; enforcing it belongs to the post flow.
const captureRadiusMeters = 100.0;

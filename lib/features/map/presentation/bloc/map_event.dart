part of 'map_bloc.dart';

sealed class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

/// Load the posts and the user position.
final class MapStarted extends MapEvent {
  const MapStarted();
}

/// The camera stopped moving; [center], [zoom] and [bounds] describe the new
/// view.
final class MapCameraMoved extends MapEvent {
  const MapCameraMoved(this.center, this.zoom, this.bounds);

  final LatLng center;
  final double zoom;

  /// Part of the map on screen.
  final LatLngBounds bounds;

  @override
  List<Object?> get props => [center, zoom, bounds];
}

/// A pin was tapped, or the selection was cleared when [postId] is null.
final class MapPostSelected extends MapEvent {
  const MapPostSelected(this.postId);

  final String? postId;

  @override
  List<Object?> get props => [postId];
}

/// The device reported a new position.
final class MapUserPositionChanged extends MapEvent {
  const MapUserPositionChanged(this.position);

  final LatLng position;

  @override
  List<Object?> get props => [position];
}

/// Time went by: posts may have expired.
final class MapClockTicked extends MapEvent {
  const MapClockTicked(this.now);

  final DateTime now;

  @override
  List<Object?> get props => [now];
}

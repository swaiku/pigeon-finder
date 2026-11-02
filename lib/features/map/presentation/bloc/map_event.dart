part of 'map_bloc.dart';

sealed class const MapEvent() extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Load the posts and the user position.
final class const MapStarted() extends MapEvent;

/// The camera stopped moving; [center], [zoom] and [bounds] describe the new
/// view.
final class const MapCameraMoved(
  final LatLng center,
  final double zoom,

  /// Part of the map on screen.
  final LatLngBounds bounds,
) extends MapEvent {
  @override
  List<Object?> get props => [center, zoom, bounds];
}

/// A pin was tapped, or the selection was cleared when [postId] is null.
final class const MapPostSelected(final String? postId) extends MapEvent {
  @override
  List<Object?> get props => [postId];
}

/// The device reported a new position.
final class const MapUserPositionChanged(final LatLng position)
    extends MapEvent {
  @override
  List<Object?> get props => [position];
}

/// Time went by: posts may have expired.
final class const MapClockTicked(final DateTime now) extends MapEvent {
  @override
  List<Object?> get props => [now];
}

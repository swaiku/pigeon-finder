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

/// The camera stopped moving; [center] and [zoom] describe the new view.
final class MapCameraMoved extends MapEvent {
  const MapCameraMoved(this.center, this.zoom);

  final LatLng center;
  final double zoom;

  @override
  List<Object?> get props => [center, zoom];
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

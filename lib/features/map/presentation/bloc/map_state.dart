part of 'map_bloc.dart';

enum MapStatus { loading, success, failure }

final class MapState extends Equatable {
  const MapState({
    this.status = MapStatus.loading,
    this.posts = const [],
    this.userPosition,
    this.selectedId,
    this.errorMessage,
    this.center,
    this.regionName,
    this.regionLevel = RegionLevel.city,
  });

  final MapStatus status;
  final List<MapPost> posts;
  final LatLng? userPosition;
  final String? selectedId;
  final String? errorMessage;
  final LatLng? center;
  final String? regionName;
  final RegionLevel regionLevel;

  MapPost? get selected {
    for (final p in posts) {
      if (p.id == selectedId) return p;
    }
    return null;
  }

  MapState copyWith({
    MapStatus? status,
    List<MapPost>? posts,
    LatLng? userPosition,
    String? Function()? selectedId,
    String? errorMessage,
    LatLng? center,
    String? regionName,
    RegionLevel? regionLevel,
  }) {
    return MapState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      userPosition: userPosition ?? this.userPosition,
      selectedId: selectedId != null ? selectedId() : this.selectedId,
      errorMessage: errorMessage ?? this.errorMessage,
      center: center ?? this.center,
      regionName: regionName ?? this.regionName,
      regionLevel: regionLevel ?? this.regionLevel,
    );
  }

  @override
  List<Object?> get props => [
    status,
    posts,
    userPosition,
    selectedId,
    errorMessage,
    center,
    regionName,
    regionLevel,
  ];
}

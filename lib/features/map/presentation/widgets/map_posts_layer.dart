import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap_plus/flutter_map_heatmap.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/map_post.dart';
import 'map_cluster_marker.dart';
import 'map_pin_marker.dart';

/// The posts on the map, drawn according to the zoom:
/// - zoomed out: a heat map of where pigeons are;
/// - in between: both, cross-fading;
/// - zoomed in: pins, with the ones that would overlap folded into bubbles
///   (by `flutter_map_marker_cluster`).
class MapPostsLayer extends StatelessWidget {
  const MapPostsLayer({
    super.key,
    required this.posts,
    required this.now,
    required this.selectedId,
    required this.onPostTap,
  });

  final List<MapPost> posts;
  final DateTime now;
  final String? selectedId;
  final ValueChanged<MapPost> onPostTap;

  /// Below this zoom only the heat map is drawn...
  static const heatOnlyZoom = 11.5;

  /// ...and from this one only the pins.
  static const pinsOnlyZoom = 13.0;

  /// Past this zoom pins are never folded: the map is close enough to tell
  /// them apart.
  static const clusterMaxZoom = 17;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final heat = ((pinsOnlyZoom - camera.zoom) / (pinsOnlyZoom - heatOnlyZoom))
        .clamp(0.0, 1.0);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (heat > 0)
          IgnorePointer(
            child: Opacity(
              opacity: heat,
              child: _HeatLayer(posts: posts),
            ),
          ),
        if (heat < 1)
          IgnorePointer(
            ignoring: heat > .5,
            child: Opacity(
              opacity: 1 - heat,
              child: MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  markers: [
                    for (final p in posts)
                      _pinMarker(p, selected: p.id == selectedId),
                  ],
                  size: const Size.square(MapClusterMarker.size),
                  maxClusterRadius: 70,
                  disableClusteringAtZoom: clusterMaxZoom,
                  // Tapping a bubble zooms in on its pins; the page already
                  // centers on a selected pin, and nothing here needs a
                  // polygon or a spiral of pins.
                  centerMarkerOnClick: false,
                  spiderfyCluster: false,
                  showPolygon: false,
                  builder: (_, markers) =>
                      MapClusterMarker(count: markers.length),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Marker _pinMarker(MapPost post, {required bool selected}) => Marker(
    key: ValueKey(post.id),
    point: post.position,
    width: MapPinMarker.size,
    height: MapPinMarker.height,
    alignment: Alignment.topCenter,
    child: MapPinMarker(
      post: post,
      now: now,
      selected: selected,
      onTap: () => onPostTap(post),
    ),
  );
}

/// Heat map of the posts, drawn by `flutter_map_heatmap_plus` as a tile layer
/// from teal (a few pigeons) through amber to red (a lot).
class _HeatLayer extends StatefulWidget {
  const _HeatLayer({required this.posts});

  final List<MapPost> posts;

  @override
  State<_HeatLayer> createState() => _HeatLayerState();
}

class _HeatLayerState extends State<_HeatLayer> {
  /// The layer caches its tiles; this tells it to draw them again.
  final _reset = StreamController<void>.broadcast();

  late final _options = HeatMapOptions(
    // The plugin scales the radius with the zoom, so this is the reach at the
    // closest zoom; far out it shrinks, hence the generous value.
    radius: 70,
    minOpacity: .2,
    gradient: {
      .3: _swatch(AppColors.iridescent),
      .6: _swatch(AppColors.grain),
      1: _swatch(AppColors.pin),
    },
  );

  late InMemoryHeatMapDataSource _source = _sourceFor(widget.posts);

  /// The plugin only takes [MaterialColor]s; every shade is the same color.
  static MaterialColor _swatch(Color color) => MaterialColor(color.toARGB32(), {
    for (final shade in [50, 100, 200, 300, 400, 500, 600, 700, 800, 900])
      shade: color,
  });

  static InMemoryHeatMapDataSource _sourceFor(List<MapPost> posts) =>
      InMemoryHeatMapDataSource(
        data: [for (final p in posts) WeightedLatLng(p.position, 1)],
      );

  @override
  void didUpdateWidget(_HeatLayer old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.posts, widget.posts)) {
      _source = _sourceFor(widget.posts);
      _reset.add(null);
    }
  }

  @override
  void dispose() {
    _reset.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The plugin cannot build its bounds from an empty list.
    if (widget.posts.isEmpty) return const SizedBox.shrink();
    return HeatMapLayer(
      heatMapDataSource: _source,
      heatMapOptions: _options,
      reset: _reset.stream,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../../core/theme/app_colors.dart';

/// OpenStreetMap standard tile layer, configured to follow
/// https://operations.osmfoundation.org/policies/tiles/:
/// - the official HTTPS URL, no prefetching or offline download;
/// - a stable User-Agent naming the app (never the library default);
/// - HTTP caching honoured by flutter_map's built-in caching provider.
///
/// The licence attribution is shown by [OsmAttribution], which must always
/// be visible on the map.
class OsmTileLayer extends StatelessWidget {
  const OsmTileLayer({super.key});

  static const urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const userAgent = 'PigeonFinder (ch.jrmy.pigeon_finder)';

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: urlTemplate,
      userAgentPackageName: 'ch.jrmy.pigeon_finder',
      tileProvider: NetworkTileProvider(headers: {'User-Agent': userAgent}),
    );
  }
}

/// "© OpenStreetMap contributors" licence notice.
class OsmAttribution extends StatelessWidget {
  const OsmAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.paper.withAlpha(0xD9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          '© OpenStreetMap contributors',
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppColors.mist, fontSize: 10),
        ),
      ),
    );
  }
}

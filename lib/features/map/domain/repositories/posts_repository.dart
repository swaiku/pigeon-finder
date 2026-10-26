import 'package:latlong2/latlong.dart';

import '../entities/map_post.dart';

/// Source of the posts shown on the map. Implementations throw a `Failure`
/// (see core/error/failures.dart) when the data cannot be loaded.
abstract interface class PostsRepository {
  /// Photos (less than 24 h old) in the surroundings of [around].
  Future<List<MapPost>> getActivePosts({required LatLng around});
}

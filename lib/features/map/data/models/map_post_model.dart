import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/map_post.dart';

part 'map_post_model.g.dart';

/// Wire format of a [MapPost]: snake_case keys, flat `latitude`/`longitude`
/// and a UTC ISO 8601 timestamp.
@JsonSerializable(fieldRename: FieldRename.snake)
class const MapPostModel({
  required final String id,
  required final String user,
  required final String place,
  required final String photoUrl,
  required final double latitude,
  required final double longitude,
  required final DateTime createdAt,
  required final int count,
  required final int points,
  required final int coos,
  final int reports = 0,
  final bool mine = false,
}) {
  factory MapPostModel.fromJson(Map<String, dynamic> json) =>
      _$MapPostModelFromJson(json);

  factory MapPostModel.fromEntity(MapPost post) => MapPostModel(
    id: post.id,
    user: post.user,
    place: post.place,
    photoUrl: post.photoUrl,
    latitude: post.position.latitude,
    longitude: post.position.longitude,
    createdAt: post.createdAt,
    count: post.count,
    points: post.points,
    coos: post.coos,
    reports: post.reports,
    mine: post.mine,
  );

  Map<String, dynamic> toJson() => _$MapPostModelToJson(this);

  MapPost toEntity() => MapPost(
    id: id,
    user: user,
    place: place,
    photoUrl: photoUrl,
    position: LatLng(latitude, longitude),
    createdAt: createdAt,
    count: count,
    points: points,
    coos: coos,
    reports: reports,
    mine: mine,
  );
}

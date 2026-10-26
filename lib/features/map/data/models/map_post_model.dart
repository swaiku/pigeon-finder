import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/map_post.dart';

part 'map_post_model.g.dart';

/// Wire format of a [MapPost]: snake_case keys, flat `latitude`/`longitude`
/// and a UTC ISO 8601 timestamp.
@JsonSerializable(fieldRename: FieldRename.snake)
class MapPostModel {
  const MapPostModel({
    required this.id,
    required this.user,
    required this.place,
    required this.photoUrl,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.count,
    required this.points,
    required this.coos,
    this.reports = 0,
    this.mine = false,
  });

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

  final String id;
  final String user;
  final String place;
  final String photoUrl;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final int count;
  final int points;
  final int coos;
  final int reports;
  final bool mine;

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

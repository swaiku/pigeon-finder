// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapPostModel _$MapPostModelFromJson(Map<String, dynamic> json) => MapPostModel(
  id: json['id'] as String,
  user: json['user'] as String,
  place: json['place'] as String,
  photoUrl: json['photo_url'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
  count: (json['count'] as num).toInt(),
  points: (json['points'] as num).toInt(),
  coos: (json['coos'] as num).toInt(),
  reports: (json['reports'] as num?)?.toInt() ?? 0,
  mine: json['mine'] as bool? ?? false,
);

Map<String, dynamic> _$MapPostModelToJson(MapPostModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'place': instance.place,
      'photo_url': instance.photoUrl,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'created_at': instance.createdAt.toIso8601String(),
      'count': instance.count,
      'points': instance.points,
      'coos': instance.coos,
      'reports': instance.reports,
      'mine': instance.mine,
    };

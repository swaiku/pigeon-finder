// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapPost _$MapPostFromJson(Map<String, dynamic> json) => MapPost(
  id: json['id'] as String,
  user: json['user'] as String,
  place: json['place'] as String,
  photoUrl: json['photo_url'] as String,
  position: _positionFromJson(_readPosition(json, 'position')),
  createdAt: DateTime.parse(json['created_at'] as String),
  count: (json['count'] as num).toInt(),
  points: (json['points'] as num).toInt(),
  coos: (json['coos'] as num).toInt(),
  reports: (json['reports'] as num?)?.toInt() ?? 0,
  mine: json['mine'] as bool? ?? false,
);

Map<String, dynamic> _$MapPostToJson(MapPost instance) => <String, dynamic>{
  'id': instance.id,
  'user': instance.user,
  'place': instance.place,
  'photo_url': instance.photoUrl,
  'created_at': instance.createdAt.toIso8601String(),
  'count': instance.count,
  'points': instance.points,
  'coos': instance.coos,
  'reports': instance.reports,
  'mine': instance.mine,
};

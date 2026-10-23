import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// A pigeon photo pinned on the map. It stays visible for [lifetime].
class MapPost extends Equatable {
  const MapPost({
    required this.id,
    required this.user,
    required this.place,
    required this.photoUrl,
    required this.position,
    required this.createdAt,
    required this.count,
    required this.points,
    required this.coos,
    this.reports = 0,
    this.mine = false,
  });

  static const lifetime = Duration(hours: 24);

  /// UUID of the post.
  final String id;
  final String user;
  final String place;

  /// Where the photo taken for this post can be downloaded from.
  final String photoUrl;
  final LatLng position;
  final DateTime createdAt;
  final int count;
  final int points;
  final int coos;
  final int reports;
  final bool mine;

  DateTime get expiresAt => createdAt.add(lifetime);

  /// Time left before the post disappears, never negative.
  Duration timeLeft({DateTime? now}) {
    final left = expiresAt.difference(now ?? DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  /// Fraction of the 24 h lifetime still remaining, in [0, 1].
  double remaining({DateTime? now}) =>
      (timeLeft(now: now).inSeconds / lifetime.inSeconds).clamp(0.0, 1.0);

  bool get flagged => reports > 0;

  @override
  List<Object?> get props => [
    id,
    user,
    place,
    photoUrl,
    position,
    createdAt,
    count,
    points,
    coos,
    reports,
    mine,
  ];
}

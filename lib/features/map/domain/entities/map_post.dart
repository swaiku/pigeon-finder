import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// A pigeon photo pinned on the map. It stays visible for [lifetime].
class const MapPost({
  /// UUID of the post.
  required final String id,
  required final String user,
  required final String place,

  /// Where the photo taken for this post can be downloaded from.
  required final String photoUrl,
  required final LatLng position,
  required final DateTime createdAt,
  required final int count,
  required final int points,
  required final int coos,
  final int reports = 0,
  final bool mine = false,
}) extends Equatable {
  static const lifetime = Duration(hours: 24);

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

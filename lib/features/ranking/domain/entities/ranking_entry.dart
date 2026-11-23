import 'package:equatable/equatable.dart';

/// How wide the leaderboard is: the user's city, their country, or everyone.
enum RankingScope { city, country, world }

/// One player of the leaderboard. Ties share the same [rank].
///
/// [nextScore] and [nextRank] are set on the user's own row only: score and
/// rank of the player just ahead, null when the user leads.
final class const RankingEntry({
  required final int rank,
  required final String username,
  required final int score,
  required final int pigeons,
  final bool isMe = false,
  final int? nextScore,
  final int? nextRank,
}) extends Equatable {
  @override
  List<Object?> get props => [
    rank,
    username,
    score,
    pigeons,
    isMe,
    nextScore,
    nextRank,
  ];
}

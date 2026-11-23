part of 'ranking_cubit.dart';

enum RankingStatus { loading, ready, failure }

final class const RankingState({
  final RankingStatus status = RankingStatus.loading,
  final RankingScope scope = RankingScope.nearby,
  final List<RankingEntry> entries = const [],
  final Map<RankingScope, String>? labels,
}) extends Equatable {
  // [labels]: city and country names of the user's position, shown on the
  // scopes; null until the user was located.

  /// Up to three best players, best first.
  List<RankingEntry> get podium => entries.take(3).toList();

  /// Players below the podium, the user's own row included.
  List<RankingEntry> get others => entries.skip(3).toList();

  /// The user's own row, null until they have scored in this scope.
  RankingEntry? get me => entries.where((e) => e.isMe).firstOrNull;

  RankingState copyWith({
    RankingStatus? status,
    RankingScope? scope,
    List<RankingEntry>? entries,
    Map<RankingScope, String>? labels,
  }) => RankingState(
    status: status ?? this.status,
    scope: scope ?? this.scope,
    entries: entries ?? this.entries,
    labels: labels ?? this.labels,
  );

  @override
  List<Object?> get props => [status, scope, entries, labels];
}

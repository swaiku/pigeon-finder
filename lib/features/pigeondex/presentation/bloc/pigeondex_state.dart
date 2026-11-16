part of 'pigeondex_cubit.dart';

enum PigeondexStatus { loading, ready, failure }

/// How the gallery is ordered: by month, by city, or by points.
enum PigeondexSort { date, place, top }

/// A titled run of photos. [key] is the first day of the month
/// (a local `DateTime`) for [PigeondexSort.date], the city (empty when
/// unknown) for [PigeondexSort.place], and null for [PigeondexSort.top].
typedef PigeondexSection = ({Object? key, List<MapPost> posts});

final class const PigeondexState({
  final PigeondexStatus status = PigeondexStatus.loading,
  final List<MapPost> posts = const [],
  final PigeondexSort sort = PigeondexSort.date,
}) extends Equatable {
  /// [posts] cut into sections for the current [sort], photos newest first
  /// inside a section (highest points first for [PigeondexSort.top]).
  List<PigeondexSection> get sections {
    final byDate = [...posts]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    switch (sort) {
      case PigeondexSort.top:
        byDate.sort((a, b) {
          final points = b.points.compareTo(a.points);
          return points != 0 ? points : b.createdAt.compareTo(a.createdAt);
        });
        return [(key: null, posts: byDate)];
      case PigeondexSort.date:
        final months = <DateTime, List<MapPost>>{};
        for (final p in byDate) {
          final local = p.createdAt.toLocal();
          (months[DateTime(local.year, local.month)] ??= []).add(p);
        }
        return [for (final e in months.entries) (key: e.key, posts: e.value)];
      case PigeondexSort.place:
        final places = <String, List<MapPost>>{};
        for (final p in byDate) {
          (places[p.place] ??= []).add(p);
        }
        // Most photographed city first, unknown places last.
        final entries = places.entries.toList()
          ..sort((a, b) {
            if (a.key.isEmpty != b.key.isEmpty) return a.key.isEmpty ? 1 : -1;
            final size = b.value.length.compareTo(a.value.length);
            return size != 0 ? size : a.key.compareTo(b.key);
          });
        return [for (final e in entries) (key: e.key, posts: e.value)];
    }
  }

  PigeondexState copyWith({
    PigeondexStatus? status,
    List<MapPost>? posts,
    PigeondexSort? sort,
  }) => PigeondexState(
    status: status ?? this.status,
    posts: posts ?? this.posts,
    sort: sort ?? this.sort,
  );

  @override
  List<Object?> get props => [status, posts, sort];
}

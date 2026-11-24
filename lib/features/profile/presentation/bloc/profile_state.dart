part of 'profile_cubit.dart';

enum ProfileStatus { loading, ready, failure }

/// Consecutive local calendar days with a photo. [expiresAt] is the local
/// midnight after which, without a new photo, the streak drops to 0; null
/// when there is no streak.
typedef Streak = ({int days, DateTime? expiresAt});

final class const ProfileState({
  final ProfileStatus status = ProfileStatus.loading,
  final Profile? profile,

  /// The user's photos, newest first.
  final List<MapPost> posts = const [],
  final bool uploadingAvatar = false,
}) extends Equatable {
  int get pigeons => posts.fold(0, (sum, p) => sum + p.count);

  int get likesReceived => posts.fold(0, (sum, p) => sum + p.coos);

  /// City of the latest photo, empty when unknown.
  String get lastPlace => posts.firstOrNull?.place ?? '';

  /// Days with at least one photo, as local midnights.
  Set<DateTime> get _activeDays => {
    for (final p in posts) _dayOf(p.createdAt.toLocal()),
  };

  int get xp => Level.xp(
    photos: posts.length,
    activeDays: _activeDays.length,
    likesGiven: profile?.likesGiven ?? 0,
  );

  Level get level => Level.of(xp);

  /// Photos still on the map, newest first.
  List<MapPost> onMap({DateTime? now}) => [
    for (final p in posts)
      if (p.timeLeft(now: now) > Duration.zero) p,
  ];

  /// The streak runs back from today, or from yesterday while today's photo
  /// can still be taken.
  Streak streak({DateTime? now}) {
    final days = _activeDays;
    var day = _dayOf(now ?? DateTime.now());
    if (!days.contains(day)) day = _previous(day);
    if (!days.contains(day)) return (days: 0, expiresAt: null);
    final expiresAt = DateTime(day.year, day.month, day.day + 2);
    var count = 0;
    for (; days.contains(day); day = _previous(day)) {
      count++;
    }
    return (days: count, expiresAt: expiresAt);
  }

  Set<ProfileBadge> get badges => {
    if (posts.length >= ProfileBadge.photographerGoal)
      ProfileBadge.photographer,
    if ((profile?.likesGiven ?? 0) >= ProfileBadge.fanGoal) ProfileBadge.fan,
    if (likesReceived >= ProfileBadge.starGoal) ProfileBadge.star,
    if (posts.any((p) => p.count >= ProfileBadge.flockGoal)) ProfileBadge.flock,
    if (posts.any(
      (p) => p.createdAt.toLocal().hour < ProfileBadge.earlyBirdHour,
    ))
      ProfileBadge.earlyBird,
  };

  // Calendar arithmetic, not 24 h steps, so DST changes don't skip a day.
  static DateTime _dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

  static DateTime _previous(DateTime day) =>
      DateTime(day.year, day.month, day.day - 1);

  ProfileState copyWith({
    ProfileStatus? status,
    Profile? profile,
    List<MapPost>? posts,
    bool? uploadingAvatar,
  }) => ProfileState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    posts: posts ?? this.posts,
    uploadingAvatar: uploadingAvatar ?? this.uploadingAvatar,
  );

  @override
  List<Object?> get props => [status, profile, posts, uploadingAvatar];
}

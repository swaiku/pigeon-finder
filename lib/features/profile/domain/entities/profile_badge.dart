/// An achievement on the profile, earned or still locked.
enum ProfileBadge {
  /// [photographerGoal] photos posted.
  photographer,

  /// [fanGoal] coos given.
  fan,

  /// [starGoal] coos received.
  star,

  /// A single photo with [flockGoal] pigeons.
  flock,

  /// A photo taken before [earlyBirdHour] (local time).
  earlyBird;

  static const photographerGoal = 10;
  static const fanGoal = 25;
  static const starGoal = 25;
  static const flockGoal = 10;
  static const earlyBirdHour = 7;
}

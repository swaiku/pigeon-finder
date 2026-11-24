import 'package:equatable/equatable.dart';

/// The signed-in user's account data. Stats derived from their posts live in
/// the profile state.
class const Profile({
  required final String username,

  /// Signed URL of the profile photo; null shows the initial placeholder.
  final String? avatarUrl,

  /// Posts the user cooed (liked).
  final int likesGiven = 0,
}) extends Equatable {
  @override
  List<Object?> get props => [username, avatarUrl, likesGiven];
}

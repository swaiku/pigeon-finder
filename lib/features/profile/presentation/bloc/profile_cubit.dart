import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/events/posts_changes.dart';
import '../../../map/domain/entities/map_post.dart';
import '../../../map/domain/repositories/posts_repository.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/profile_badge.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_state.dart';

/// The user's profile and stats, reloaded when [PostsChanges] signals a new
/// post.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this._profile,
    required this._posts,
    PostsChanges? changes,
  }) : super(const ProfileState()) {
    _changesSub = changes?.stream.listen((_) => unawaited(load()));
    _refresh = Timer.periodic(refreshEvery, (_) => unawaited(load()));
  }

  /// The page lives as long as the session but photo URLs are signed for
  /// 1 h: reload before they expire.
  static const refreshEvery = Duration(minutes: 50);

  final ProfileRepository _profile;
  // Reads through the map's PostsRepository to share its signed-URL cache.
  final PostsRepository _posts;
  StreamSubscription<void>? _changesSub;
  late final Timer _refresh;

  /// Loads the profile and every photo; whether it worked. A refresh that
  /// fails keeps what is already shown.
  Future<bool> load() async {
    if (state.status != ProfileStatus.ready) {
      emit(state.copyWith(status: ProfileStatus.loading));
    }
    try {
      final profile = await _profile.getProfile();
      final posts = await _posts.getMyPosts();
      if (!isClosed) {
        emit(
          state.copyWith(
            status: ProfileStatus.ready,
            profile: profile,
            posts: posts,
          ),
        );
      }
      return true;
    } on Failure catch (e) {
      debugPrint('Loading the profile failed: ${e.message}');
      if (!isClosed && state.status != ProfileStatus.ready) {
        emit(state.copyWith(status: ProfileStatus.failure));
      }
      return false;
    }
  }

  /// Replaces the profile photo; whether it worked.
  Future<bool> changeAvatar(File photo) async {
    final profile = state.profile;
    if (profile == null || state.uploadingAvatar) return false;
    emit(state.copyWith(uploadingAvatar: true));
    try {
      final url = await _profile.setAvatar(photo);
      if (!isClosed) {
        emit(
          state.copyWith(
            uploadingAvatar: false,
            profile: Profile(
              username: profile.username,
              avatarUrl: url,
              likesGiven: profile.likesGiven,
            ),
          ),
        );
      }
      return true;
    } on Failure catch (e) {
      debugPrint('Changing the avatar failed: ${e.message}');
      if (!isClosed) emit(state.copyWith(uploadingAvatar: false));
      return false;
    }
  }

  @override
  Future<void> close() {
    _refresh.cancel();
    unawaited(_changesSub?.cancel());
    return super.close();
  }
}

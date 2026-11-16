import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/events/posts_changes.dart';
import '../../../map/domain/entities/map_post.dart';
import '../../../map/domain/repositories/posts_repository.dart';

part 'pigeondex_state.dart';

/// The user's own photos, reloaded when [PostsChanges] signals a new post.
class PigeondexCubit extends Cubit<PigeondexState> {
  PigeondexCubit({required this._posts, PostsChanges? changes})
    : super(const PigeondexState()) {
    _changesSub = changes?.stream.listen((_) => unawaited(load()));
    _refresh = Timer.periodic(refreshEvery, (_) => unawaited(load()));
  }

  /// The page lives as long as the session but photo URLs are signed for
  /// 1 h: reload before they expire.
  static const refreshEvery = Duration(minutes: 50);

  final PostsRepository _posts;
  StreamSubscription<void>? _changesSub;
  late final Timer _refresh;

  /// Loads every photo; whether it worked. A refresh that fails keeps the
  /// photos already shown.
  Future<bool> load() async {
    if (state.status != PigeondexStatus.ready) {
      emit(state.copyWith(status: PigeondexStatus.loading));
    }
    try {
      final posts = await _posts.getMyPosts();
      if (!isClosed) {
        emit(state.copyWith(status: PigeondexStatus.ready, posts: posts));
      }
      return true;
    } on Failure catch (e) {
      debugPrint('Loading the Pigeondex failed: ${e.message}');
      if (!isClosed && state.status != PigeondexStatus.ready) {
        emit(state.copyWith(status: PigeondexStatus.failure));
      }
      return false;
    }
  }

  void setSort(PigeondexSort sort) => emit(state.copyWith(sort: sort));

  @override
  Future<void> close() {
    _refresh.cancel();
    unawaited(_changesSub?.cancel());
    return super.close();
  }
}

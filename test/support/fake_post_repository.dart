import 'package:pigeon_finder/core/error/failures.dart';
import 'package:pigeon_finder/features/post/domain/entities/new_post.dart';
import 'package:pigeon_finder/features/post/domain/repositories/post_repository.dart';

/// Records the published posts, or throws [failure] when set.
class FakePostRepository implements PostRepository {
  FakePostRepository({this.failure});

  Failure? failure;
  final published = <NewPost>[];

  @override
  Future<void> publish(NewPost post) async {
    if (failure case final f?) throw f;
    published.add(post);
  }
}

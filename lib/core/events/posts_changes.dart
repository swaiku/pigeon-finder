import 'dart:async';

/// App-wide signal that the set of posts changed, e.g. after publishing one.
/// Lets the map refresh without the post and map features importing each
/// other.
class PostsChanges {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notify() => _controller.add(null);

  Future<void> dispose() => _controller.close();
}

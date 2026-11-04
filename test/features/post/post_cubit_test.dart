import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:pigeon_finder/core/error/failures.dart';
import 'package:pigeon_finder/features/map/data/datasources/location_data_source.dart';
import 'package:pigeon_finder/features/map/data/repositories/location_repository_impl.dart';
import 'package:pigeon_finder/features/post/presentation/bloc/post_cubit.dart';

import '../../support/fake_location_data_source.dart';
import '../../support/fake_post_repository.dart';

class _DeniedLocation implements LocationDataSource {
  const _DeniedLocation();

  @override
  Future<LatLng> getCurrentPosition() async =>
      throw const PermissionFailure('denied');

  @override
  Future<bool> requestPermission() async => false;

  @override
  Stream<LatLng> watchPosition() => const Stream.empty();
}

class _NoFixLocation extends _DeniedLocation {
  const _NoFixLocation();

  @override
  Future<LatLng> getCurrentPosition() async =>
      throw const LocationFailure('no fix');
}

void main() {
  late FakePostRepository posts;

  PostCubit build({
    LocationDataSource location = const FakeLocationDataSource(),
  }) => PostCubit(posts: posts, location: LocationRepositoryImpl(location));

  setUp(() => posts = FakePostRepository());

  test('prepare stores the user position', () async {
    final cubit = build();
    await cubit.prepare();
    expect(cubit.state.position, FakeLocationDataSource.position);
    expect(cubit.state.error, isNull);
  });

  test('publish sends the photo, position and description', () async {
    final cubit = build();
    await cubit.prepare();

    expect(
      await cubit.publish(photoPath: '/tmp/p.jpg', description: 'Hi'),
      isTrue,
    );
    expect(cubit.state.status, PostStatus.success);
    final post = posts.published.single;
    expect(post.photoPath, '/tmp/p.jpg');
    expect(post.description, 'Hi');
    expect(post.position, FakeLocationDataSource.position);
    expect(post.pigeonCount, 1);
  });

  test('publish locates the user when prepare was not called', () async {
    final cubit = build();
    expect(await cubit.publish(photoPath: '/tmp/p.jpg'), isTrue);
    expect(posts.published.single.position, FakeLocationDataSource.position);
  });

  test('a denied location blocks publishing', () async {
    final cubit = build(location: const _DeniedLocation());
    expect(await cubit.publish(photoPath: '/tmp/p.jpg'), isFalse);
    expect(cubit.state.error, PostError.locationDenied);
    expect(posts.published, isEmpty);
  });

  test('a missing GPS fix blocks publishing', () async {
    final cubit = build(location: const _NoFixLocation());
    expect(await cubit.publish(photoPath: '/tmp/p.jpg'), isFalse);
    expect(cubit.state.error, PostError.locationUnavailable);
  });

  for (final (failure, error) in <(Failure, PostError)>[
    (
      const RateLimitFailure('slow down', Duration(hours: 1)),
      PostError.rateLimited,
    ),
    (const NetworkFailure('offline'), PostError.network),
    (const PhotoTooLargeFailure('big'), PostError.tooLarge),
    (const ServerFailure('boom'), PostError.unknown),
  ]) {
    test('${failure.runtimeType} shows ${error.name}', () async {
      posts.failure = failure;
      final cubit = build();
      expect(await cubit.publish(photoPath: '/tmp/p.jpg'), isFalse);
      expect(cubit.state.status, PostStatus.failure);
      expect(cubit.state.error, error);
    });
  }

  test('dismissError clears the error', () async {
    posts.failure = const NetworkFailure('offline');
    final cubit = build();
    await cubit.publish(photoPath: '/tmp/p.jpg');
    cubit.dismissError();
    expect(cubit.state.error, isNull);
    expect(cubit.state.status, PostStatus.idle);
  });
}

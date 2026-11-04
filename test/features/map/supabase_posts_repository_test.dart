import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:pigeon_finder/features/map/data/datasources/posts_remote_data_source.dart';
import 'package:pigeon_finder/features/map/data/repositories/supabase_posts_repository.dart';

Map<String, dynamic> _row(String id, {String? city}) => {
  'id': id,
  'username': 'grisou',
  'city': city,
  'photo_path': 'u1/$id.jpg',
  'latitude': 46.52,
  'longitude': 6.63,
  'created_at': '2026-11-03T10:00:00+00:00',
  'pigeon_count': 1,
  'points': 10,
  'coos': 4,
  'reports': 1,
  'mine': true,
  'liked_by_me': false,
};

/// Two rows from `posts_around`; only the first photo can be signed.
class _FakeRemote implements PostsRemoteDataSource {
  ({double lat, double lng, int radius})? lastQuery;
  final signedBatches = <List<String>>[];

  @override
  Future<List<Map<String, dynamic>>> postsAround({
    required double latitude,
    required double longitude,
    required int radiusMeters,
  }) async {
    lastQuery = (lat: latitude, lng: longitude, radius: radiusMeters);
    return [_row('a1', city: 'Lausanne'), _row('b2')];
  }

  @override
  Future<Map<String, String>> signPhotoUrls(List<String> paths) async {
    signedBatches.add(paths);
    return {
      if (paths.contains('u1/a1.jpg')) 'u1/a1.jpg': 'https://signed/a1',
    };
  }
}

void main() {
  test(
    'maps posts_around rows and drops photos that cannot be signed',
    () async {
      final remote = _FakeRemote();
      final posts = await SupabasePostsRepository(remote)
          .getActivePosts(around: const LatLng(46.5, 6.6));

      expect(remote.lastQuery, (
        lat: 46.5,
        lng: 6.6,
        radius: SupabasePostsRepository.radiusMeters,
      ));
      final post = posts.single;
      expect(post.id, 'a1');
      expect(post.user, 'grisou');
      expect(post.place, 'Lausanne');
      expect(post.photoUrl, 'https://signed/a1');
      expect(post.position, const LatLng(46.52, 6.63));
      expect(post.createdAt, DateTime.utc(2026, 11, 3, 10));
      expect(post.count, 1);
      expect(post.points, 10);
      expect(post.coos, 4);
      expect(post.reports, 1);
      expect(post.mine, isTrue);
    },
  );

  test('a refetch reuses signed URLs so photos stay cached', () async {
    final remote = _FakeRemote();
    final repo = SupabasePostsRepository(remote);
    const around = LatLng(46.5, 6.6);

    await repo.getActivePosts(around: around);
    final posts = await repo.getActivePosts(around: around);

    // Only b2, which could not be signed, is retried.
    expect(remote.signedBatches, [
      ['u1/a1.jpg', 'u1/b2.jpg'],
      ['u1/b2.jpg'],
    ]);
    expect(posts.single.photoUrl, 'https://signed/a1');
  });

  test('a missing city becomes an empty place', () {
    final post = SupabasePostsRepository.fromRow(_row('b2'), 'url');
    expect(post.place, '');
  });
}

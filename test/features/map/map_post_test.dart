import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:pigeon_finder/features/map/data/models/map_post_model.dart';
import 'package:pigeon_finder/features/map/domain/entities/map_post.dart';

void main() {
  final json = {
    'id': '3f2b8c1e-5a4d-4e6f-9b7a-0c1d2e3f4a51',
    'user': 'grisou',
    'place': 'Bastille',
    'photo_url': 'https://example.com/pigeon.jpg',
    'latitude': 48.8532,
    'longitude': 2.3692,
    'created_at': '2026-10-13T10:00:00.000Z',
    'count': 1,
    'points': 10,
    'coos': 1,
    'reports': 2,
    'mine': false,
  };

  test('MapPostModel round-trips through JSON', () {
    expect(MapPostModel.fromJson(json).toJson(), json);
  });

  test('toEntity maps the position and the timestamp', () {
    final post = MapPostModel.fromJson(json).toEntity();
    expect(post.position, const LatLng(48.8532, 2.3692));
    expect(post.createdAt, DateTime.utc(2026, 10, 13, 10));
  });

  test('the model survives a trip through the entity', () {
    final post = MapPostModel.fromJson(json).toEntity();
    expect(MapPostModel.fromEntity(post).toJson(), json);
  });

  test('a post expires 24 h after its creation', () {
    final post = MapPostModel.fromJson(json).toEntity();
    final now = DateTime.utc(2026, 10, 13, 22);
    expect(post.timeLeft(now: now), const Duration(hours: 12));
    expect(post.remaining(now: now), 0.5);
    expect(
      post.timeLeft(now: post.expiresAt.add(const Duration(minutes: 1))),
      Duration.zero,
    );
    expect(MapPost.lifetime, const Duration(hours: 24));
  });
}

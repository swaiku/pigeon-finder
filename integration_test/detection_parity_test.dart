// The release on the phone itself (GPU when it compiles), on photos pushed
// to the app's own folder:
//
// adb push pigeon1.png /sdcard/Android/data/ch.jrmy.pigeon_finder/files/parity/
// flutter test integration_test/detection_parity_test.dart
//
// Prints one line per bird, to compare with predict_photo.py.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pigeon_finder/features/detection/data/repositories/litert_detection_repository.dart';

const _dir = '/sdcard/Android/data/ch.jrmy.pigeon_finder/files/parity';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('counts the pigeons of the pushed photos', (tester) async {
    final photos = Directory(_dir).existsSync()
        ? (Directory(_dir).listSync().whereType<File>().toList()
            ..sort((a, b) => a.path.compareTo(b.path)))
        : <File>[];
    if (photos.isEmpty) {
      markTestSkipped('No photo in $_dir');
      return;
    }
    final repository = LiteRtDetectionRepository();
    await tester.runAsync(() async {
      final load = Stopwatch()..start();
      await repository.load();
      // ignore: avoid_print
      print('models loaded in ${load.elapsedMilliseconds} ms');
      for (final photo in photos) {
        for (final run in [1, 2]) {
          final r = await repository.detect(photo.path);
          // ignore: avoid_print
          print(
            '${photo.uri.pathSegments.last} run $run: ${r.count} birds, '
            '${r.inferenceTime.inMilliseconds} ms',
          );
          if (run == 2) continue;
          for (final b in r.birds) {
            // ignore: avoid_print
            print(
              '  [${[b.left, b.top, b.right, b.bottom].map((v) => v.round()).join(', ')}] '
              '${b.score.toStringAsFixed(3)} ${b.species} '
              '${b.confidence.toStringAsFixed(3)}${b.abstained ? ' (abstained)' : ''}',
            );
          }
          expect(r.count, greaterThan(0));
        }
      }
    });
  });
}

// Parity with piaf's predict_photo.py: runs the bundled release with LiteRT
// (CPU, on the host) on photos the reference already answered.
//
// PARITY_REFERENCE=reference.json flutter test test/features/detection/parity_test.dart
// where reference.json maps a photo path to the reference birds:
// [{"box": [x0, y0, x1, y1], "score", "species", "confidence", "abstained"}].
// Skipped without it.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_litert/flutter_litert.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pigeon_finder/features/detection/data/pipeline/pigeon_pipeline.dart';
import 'package:pigeon_finder/features/detection/data/pipeline/release_manifest.dart';

void main() {
  final path = Platform.environment['PARITY_REFERENCE'];
  final reference = path == null
      ? const <String, dynamic>{}
      : jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  final manifest = ReleaseManifest.fromJson(
    jsonDecode(File('assets/models/manifest.json').readAsStringSync())
        as Map<String, dynamic>,
  );
  CompiledModel model(String role) => CompiledModel.fromBufferWithConfig(
    File('assets/models/${manifest.files[role]}').readAsBytesSync(),
    config: const CompiledModelConfig.cpu(),
  );

  for (final MapEntry(key: photo, value: birds) in reference.entries) {
    test('same birds as predict_photo.py on $photo', () {
      final detector = model('detector');
      final classifier = model('classifier');
      final result = runPipeline(
        decodePhoto(File(photo).readAsBytesSync()),
        manifest,
        detector: (x) => detector.run([x]).first,
        classifier: (x) => classifier.run([x]).first,
      );
      final expected = <Map<String, dynamic>>[
        for (final b in birds as List<dynamic>) b as Map<String, dynamic>,
      ];
      var worstBox = 0.0, worstScore = 0.0, worstProb = 0.0, species = 0;
      for (final bird in result.birds) {
        // The reference bird with the most overlap: close scores may swap order.
        Map<String, dynamic>? r;
        var bestIou = 0.5;
        for (final e in expected) {
          final v = [
            for (final x in e['box'] as List<dynamic>) (x as num).toDouble(),
          ];
          final o = iou(
            (left: v[0], top: v[1], right: v[2], bottom: v[3], score: 0),
            (
              left: bird.left,
              top: bird.top,
              right: bird.right,
              bottom: bird.bottom,
              score: 0,
            ),
          );
          if (o > bestIou) (bestIou, r) = (o, e);
        }
        final line =
            '[${[bird.left, bird.top, bird.right, bird.bottom].map((v) => v.round()).join(', ')}] '
            '${bird.score.toStringAsFixed(3)} ${bird.species} ${bird.confidence.toStringAsFixed(3)}'
            '${bird.abstained ? ' (abstained)' : ''}';
        if (r == null) {
          printOnFailure('extra $line');
          continue;
        }
        final box = [
          for (final v in r['box'] as List<dynamic>) (v as num).toDouble(),
        ];
        final ours = [bird.left, bird.top, bird.right, bird.bottom];
        for (var k = 0; k < 4; k++) {
          worstBox = [
            worstBox,
            (ours[k] - box[k]).abs(),
          ].reduce((a, b) => a > b ? a : b);
        }
        worstScore = [
          worstScore,
          (bird.score - (r['score'] as num)).abs(),
        ].reduce((a, b) => a > b ? a : b);
        worstProb = [
          worstProb,
          (bird.confidence - (r['confidence'] as num)).abs(),
        ].reduce((a, b) => a > b ? a : b);
        if (bird.species == r['species']) species++;
        // ignore: avoid_print
        print(
          '$line   ref ${r['species']} ${(r['confidence'] as num).toStringAsFixed(3)}',
        );
      }
      // ignore: avoid_print
      print(
        '$photo: ${result.count} birds (reference ${expected.length}), '
        'same species $species, worst box ${worstBox.toStringAsFixed(2)} px, '
        'worst score ${worstScore.toStringAsFixed(4)}, worst prob ${worstProb.toStringAsFixed(4)}',
      );
      expect(result.count, expected.length);
      expect(species, expected.length);
      expect(worstBox, lessThan(2));
      expect(worstProb, lessThan(0.02)); // contracts/README.md parity limit
      detector.close();
      classifier.close();
    }, timeout: const Timeout(Duration(minutes: 2)));
  }
  if (reference.isEmpty) {
    test('parity', () {}, skip: 'PARITY_REFERENCE not set');
  }
}

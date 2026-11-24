import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pigeon_finder/features/detection/data/pipeline/pigeon_pipeline.dart';
import 'package:pigeon_finder/features/detection/data/pipeline/release_manifest.dart';

ReleaseManifest manifest() => ReleaseManifest.fromJson(
  jsonDecode(File('assets/models/manifest.json').readAsStringSync())
      as Map<String, dynamic>,
);

RgbImage solid(int w, int h, int value) =>
    RgbImage(w, h, Uint8List(w * h * 3)..fillRange(0, w * h * 3, value));

Box box(double l, double t, double r, double b, [double score = 1]) =>
    (left: l, top: t, right: r, bottom: b, score: score);

void main() {
  test('the manifest gives sizes, thresholds and classes', () {
    final m = manifest();
    expect(m.detector.size, 512);
    expect(m.classifier.size, 224);
    expect(m.classes.last, 'other');
    expect(m.nmsIou, 0.7);
    expect(m.files['detector'], 'detector.tflite');
  });

  test('roundHalfEven rounds as Python', () {
    expect([0.5, 1.5, 2.5, -0.5, 2.4, 2.6].map(roundHalfEven), [
      0,
      2,
      2,
      0,
      2,
      3,
    ]);
  });

  group('letterbox', () {
    test('keeps the ratio and centres a landscape photo', () {
      final r = letterbox(solid(2048, 1536, 200), 512);
      expect(r.ratio, 0.25);
      expect((r.left, r.top), (0, 64));
      expect(r.image.rgb[0], letterboxPad); // top padding
      expect(r.image.rgb[(64 * 512) * 3], 200); // first photo row
      expect(r.image.rgb[(448 * 512) * 3], letterboxPad); // bottom padding
    });

    test('maps a box back to the photo and clips it', () {
      final r = letterbox(solid(2048, 1536, 0), 512);
      final b = unletterbox(
        box(-10, 64, 256, 128),
        r.ratio,
        r.left,
        r.top,
        2048,
        1536,
      );
      expect([b.left, b.top, b.right, b.bottom], [0, 0, 1024, 256]);
    });
  });

  test('bilinear does not smooth when it halves', () {
    // Stripes of 2 px: OpenCV gives the average of each pair, not a blur.
    final rgb = Uint8List(4 * 1 * 3);
    rgb.setAll(0, [0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255]);
    expect(resizeBilinear(RgbImage(4, 1, rgb), 2, 1).rgb, [
      0,
      0,
      0,
      255,
      255,
      255,
    ]);
  });

  test('decodes the detector output in letterboxed pixels', () {
    // 2 anchors, rows cx, cy, w, h, score.
    final out = Float32List.fromList([
      0.5,
      0.25,
      0.5,
      0.25,
      0.2,
      0.1,
      0.2,
      0.1,
      0.9,
      0.4,
    ]);
    final boxes = decodeDetections(out, 512, 0.5);
    expect(boxes, hasLength(1));
    final b = boxes.single;
    expect(
      [b.left, b.top, b.right, b.bottom, b.score],
      [
        closeTo(204.8, 1e-3),
        closeTo(204.8, 1e-3),
        closeTo(307.2, 1e-3),
        closeTo(307.2, 1e-3),
        closeTo(0.9, 1e-6),
      ],
    );
  });

  test('NMS keeps the best of overlapping boxes, most confident first', () {
    final kept = nms([
      box(0, 0, 10, 10, 0.6),
      box(1, 0, 11, 10, 0.9), // iou 0.82 with the first
      box(20, 20, 30, 30, 0.7),
    ], 0.7);
    expect(kept.map((b) => b.score), [0.9, 0.7]);
  });

  test('the square crop is centred on the box with a 15 % margin', () {
    final r = squareCropRect(box(100, 100, 200, 150));
    expect((r.left, r.top, r.side), (85, 60, 130));
  });

  test('the crop is black outside the photo', () {
    final c = cropSquare(solid(10, 10, 255), -5, -5, 10);
    expect(c.rgb[0], 0); // outside
    expect(c.rgb[(5 * 10 + 5) * 3], 255); // photo pixel (0, 0)
  });

  test('bicubic keeps a flat image flat', () {
    expect(resizeBicubic(solid(300, 300, 77), 224, 224).rgb.toSet(), {77});
    expect(resizeBicubic(solid(50, 50, 77), 224, 224).rgb.toSet(), {77});
  });

  group('runPipeline', () {
    final m = manifest();
    // One box in the middle of the letterboxed input.
    Float32List detector(Float32List _) =>
        Float32List.fromList([0.5, 0.5, 0.2, 0.2, 0.9]);

    test('names the species when the classifier is sure', () {
      final r = runPipeline(
        solid(1024, 1024, 100),
        m,
        detector: detector,
        classifier: (_) => Float32List.fromList([0.1, 0.8, 0.05, 0.05]),
      );
      expect(r.count, 1);
      final b = r.birds.single;
      expect(b.species, m.classes[1]);
      expect(b.abstained, isFalse);
      expect([b.left, b.right], [closeTo(409.6, 1e-3), closeTo(614.4, 1e-3)]);
    });

    test('abstains to other below the abstention threshold', () {
      final b = runPipeline(
        solid(1024, 1024, 100),
        m,
        detector: detector,
        classifier: (_) => Float32List.fromList([0.5, 0.3, 0.1, 0.1]),
      ).birds.single;
      expect(b.species, 'other');
      expect(b.confidence, closeTo(0.5, 1e-6));
      expect(b.abstained, isTrue);
    });
  });
}

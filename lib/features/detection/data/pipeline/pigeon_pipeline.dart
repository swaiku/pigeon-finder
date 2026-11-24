import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../domain/entities/detection_result.dart';
import 'release_manifest.dart';

/// The pipeline of `piaf/modelling/src/scripts/predict_photo.py`, step by
/// step, so that the phone and the reference find the same birds. Pure Dart:
/// the models are passed in as functions.

/// An 8-bit RGB image, rows top to bottom, 3 bytes per pixel.
class const RgbImage(final int width, final int height, final Uint8List rgb);

/// A box in pixels, with the detector score.
typedef Box = ({
  double left,
  double top,
  double right,
  double bottom,
  double score,
});

/// Runs one model: a float32 input tensor in, the first output tensor out.
typedef RunModel = Float32List Function(Float32List input);

/// Grey of the Ultralytics letterbox.
const letterboxPad = 114;

/// Margin of the square crop on each side of the longest box side, as the
/// `crop_species` stage of piaf (not in the manifest: fixed with P1).
const cropMargin = 0.15;

/// Decodes a JPEG or PNG, applies its EXIF orientation and drops alpha.
RgbImage decodePhoto(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const FormatException('Not an image');
  final upright = img.bakeOrientation(decoded);
  final rgb = upright
      .convert(format: img.Format.uint8, numChannels: 3)
      .getBytes(order: img.ChannelOrder.rgb);
  return RgbImage(upright.width, upright.height, rgb);
}

/// Python's `round`: halves go to the even neighbour.
int roundHalfEven(double x) {
  final floor = x.floorToDouble();
  final diff = x - floor;
  if (diff != 0.5) return x.round();
  final f = floor.toInt();
  return f.isEven ? f : f + 1;
}

/// OpenCV's `INTER_LINEAR` (no antialiasing), with its 11-bit coefficients.
RgbImage resizeBilinear(RgbImage src, int width, int height) {
  const one = 2048;
  ({Int32List index, Int32List w0, Int32List w1}) axis(
    int inSize,
    int outSize,
  ) {
    final index = Int32List(outSize);
    final w0 = Int32List(
      outSize,
    ); // weights of index and index + 1, out of 2048
    final w1 = Int32List(outSize);
    final scale = inSize / outSize;
    for (var d = 0; d < outSize; d++) {
      // In float32, as OpenCV: it moves a coefficient by 1 now and then.
      var f = _f32((d + 0.5) * scale - 0.5);
      var s = f.floor();
      f = _f32(f - s);
      if (s < 0) {
        f = 0;
        s = 0;
      }
      if (s >= inSize - 1) {
        f = 0;
        s = inSize - 1;
      }
      index[d] = s;
      w0[d] = _rint(_f32((1 - f) * one));
      w1[d] = _rint(_f32(f * one));
    }
    return (index: index, w0: w0, w1: w1);
  }

  final xs = axis(src.width, width);
  final ys = axis(src.height, height);
  final out = Uint8List(width * height * 3);
  final stride = src.width * 3;
  for (var y = 0; y < height; y++) {
    final y0 = ys.index[y];
    final y1 = math.min(y0 + 1, src.height - 1);
    final (b0, b1) = (ys.w0[y], ys.w1[y]);
    for (var x = 0; x < width; x++) {
      final x0 = xs.index[x];
      final x1 = math.min(x0 + 1, src.width - 1);
      final (a0, a1) = (xs.w0[x], xs.w1[x]);
      for (var c = 0; c < 3; c++) {
        int row(int yy) =>
            src.rgb[yy * stride + x0 * 3 + c] * a0 +
            src.rgb[yy * stride + x1 * 3 + c] * a1;
        // The vertical pass of OpenCV's SIMD path (VResizeLinearVec_32s8u),
        // which rounds a little differently from its scalar tail.
        final v =
            ((((row(y0) >> 4) * b0) >> 16) +
                (((row(y1) >> 4) * b1) >> 16) +
                2) >>
            2;
        out[(y * width + x) * 3 + c] = v.clamp(0, 255);
      }
    }
  }
  return RgbImage(width, height, out);
}

final _f32Box = Float32List(1);
double _f32(double x) => (_f32Box..[0] = x)[0];

/// OpenCV's `cvRound`: halves go to the even neighbour.
int _rint(double x) => roundHalfEven(x);

/// Resize keeping the ratio, centred on grey. Returns the image, the scale
/// and the left and top padding.
({RgbImage image, double ratio, int left, int top}) letterbox(
  RgbImage photo,
  int size,
) {
  final r = math.min(size / photo.width, size / photo.height);
  final w = roundHalfEven(photo.width * r);
  final h = roundHalfEven(photo.height * r);
  final left = roundHalfEven((size - w) / 2 - 0.1);
  final top = roundHalfEven((size - h) / 2 - 0.1);
  final resized = resizeBilinear(photo, w, h);
  final out = Uint8List(size * size * 3)
    ..fillRange(0, size * size * 3, letterboxPad);
  for (var y = 0; y < h; y++) {
    out.setRange(
      ((top + y) * size + left) * 3,
      ((top + y) * size + left + w) * 3,
      resized.rgb,
      y * w * 3,
    );
  }
  return (image: RgbImage(size, size, out), ratio: r, left: left, top: top);
}

/// Float tensor of [image] with the manifest's normalization, channels first
/// (NCHW, the detector) or last (NHWC, the classifier).
Float32List toTensor(
  RgbImage image,
  ModelInput input, {
  required bool channelsFirst,
}) {
  final n = image.width * image.height;
  final out = Float32List(n * 3);
  for (var i = 0; i < n; i++) {
    for (var c = 0; c < 3; c++) {
      final v =
          (image.rgb[i * 3 + c] * input.scale - input.mean[c]) / input.std[c];
      out[channelsFirst ? c * n + i : i * 3 + c] = v;
    }
  }
  return out;
}

/// Boxes above [threshold] from the detector output `5 x anchors`: centre x,
/// centre y, width, height (divided by [size]) and score. In pixels of the
/// letterboxed input.
List<Box> decodeDetections(Float32List out, int size, double threshold) {
  final anchors = out.length ~/ 5;
  return [
    for (var i = 0; i < anchors; i++)
      if (out[4 * anchors + i] >= threshold)
        _box(
          out[i] * size,
          out[anchors + i] * size,
          out[2 * anchors + i] * size,
          out[3 * anchors + i] * size,
          out[4 * anchors + i],
        ),
  ];
}

Box _box(double cx, double cy, double w, double h, double score) => (
  left: cx - w / 2,
  top: cy - h / 2,
  right: cx + w / 2,
  bottom: cy + h / 2,
  score: score,
);

double iou(Box a, Box b) {
  final w = math.max(
    0.0,
    math.min(a.right, b.right) - math.max(a.left, b.left),
  );
  final h = math.max(
    0.0,
    math.min(a.bottom, b.bottom) - math.max(a.top, b.top),
  );
  final inter = w * h;
  double area(Box z) => (z.right - z.left) * (z.bottom - z.top);
  return inter / (area(a) + area(b) - inter);
}

/// Greedy NMS: drops a box overlapping a better one by more than
/// [threshold]. Most confident first.
List<Box> nms(List<Box> boxes, double threshold) {
  final order = [...boxes]..sort((a, b) => b.score.compareTo(a.score));
  final keep = <Box>[];
  for (final box in order) {
    if (keep.every((k) => iou(k, box) <= threshold)) keep.add(box);
  }
  return keep;
}

/// From letterboxed pixels back to the photo, clipped to it.
Box unletterbox(Box b, double ratio, int left, int top, int width, int height) {
  double x(double v) => ((v - left) / ratio).clamp(0, width.toDouble());
  double y(double v) => ((v - top) / ratio).clamp(0, height.toDouble());
  return (
    left: x(b.left),
    top: y(b.top),
    right: x(b.right),
    bottom: y(b.bottom),
    score: b.score,
  );
}

/// The square cut around a box: centred, side `max(w, h) * (1 + 2 * margin)`.
({int left, int top, int side}) squareCropRect(Box b) {
  final cx = (b.left + b.right) / 2;
  final cy = (b.top + b.bottom) / 2;
  final side =
      math.max(b.right - b.left, b.bottom - b.top) * (1 + 2 * cropMargin);
  return (
    left: roundHalfEven(cx - side / 2),
    top: roundHalfEven(cy - side / 2),
    side: side.toInt(),
  );
}

/// The square at ([left], [top]) of [side] pixels, black outside the photo.
RgbImage cropSquare(RgbImage photo, int left, int top, int side) {
  final out = Uint8List(side * side * 3);
  final x0 = math.max(0, left);
  final x1 = math.min(photo.width, left + side);
  if (x1 <= x0) return RgbImage(side, side, out);
  for (var y = math.max(0, top); y < math.min(photo.height, top + side); y++) {
    out.setRange(
      ((y - top) * side + x0 - left) * 3,
      ((y - top) * side + x1 - left) * 3,
      photo.rgb,
      (y * photo.width + x0) * 3,
    );
  }
  return RgbImage(side, side, out);
}

/// Pillow's `Image.resize(..., BICUBIC)`: bicubic (a = -0.5) widened when
/// shrinking, horizontal pass then vertical, 8 bits in between.
RgbImage resizeBicubic(RgbImage src, int width, int height) {
  final horizontal = _resample(src.rgb, src.width, src.height, width, true);
  final both = _resample(horizontal, width, src.height, height, false);
  return RgbImage(width, height, both);
}

double _bicubic(double x) {
  const a = -0.5;
  x = x.abs();
  if (x < 1) return ((a + 2) * x - (a + 3)) * x * x + 1;
  if (x < 2) return (((x - 5) * x + 8) * x - 4) * a;
  return 0;
}

/// One pass of Pillow's `ImagingResampleInner` on 8-bit pixels.
Uint8List _resample(Uint8List rgb, int w, int h, int outSize, bool alongX) {
  const bits = 22; // PRECISION_BITS of Pillow
  final inSize = alongX ? w : h;
  if (inSize == outSize) return rgb;
  final scale = inSize / outSize;
  final filterScale = math.max(scale, 1.0);
  final support = 2.0 * filterScale;
  final out = Uint8List((alongX ? outSize * h : w * outSize) * 3);
  for (var o = 0; o < outSize; o++) {
    final center = (o + 0.5) * scale;
    final lo = math.max(0, (center - support + 0.5).toInt());
    final hi = math.min(inSize, (center + support + 0.5).toInt());
    final k = [
      for (var i = lo; i < hi; i++) _bicubic((i - center + 0.5) / filterScale),
    ];
    final sum = k.fold(0.0, (s, v) => s + v);
    final fixed = [
      for (final v in k)
        ((sum == 0 ? v : v / sum) * (1 << bits) + (v < 0 ? -0.5 : 0.5))
            .truncate(),
    ];
    final lines = alongX ? h : w;
    for (var line = 0; line < lines; line++) {
      for (var c = 0; c < 3; c++) {
        var acc = 1 << (bits - 1);
        for (var j = 0; j < fixed.length; j++) {
          final i = lo + j;
          acc += rgb[(alongX ? line * w + i : i * w + line) * 3 + c] * fixed[j];
        }
        out[(alongX ? line * outSize + o : o * w + line) * 3 + c] =
            (acc >> bits).clamp(0, 255);
      }
    }
  }
  return out;
}

/// Index of the highest value, the first one on ties (as numpy's argmax).
int argmax(List<double> values) {
  var best = 0;
  for (var i = 1; i < values.length; i++) {
    if (values[i] > values[best]) best = i;
  }
  return best;
}

/// The whole photo to result path, given the two models.
DetectionResult runPipeline(
  RgbImage photo,
  ReleaseManifest manifest, {
  required RunModel detector,
  required RunModel classifier,
}) {
  final size = manifest.detector.size;
  final boxed = letterbox(photo, size);
  final out = detector(
    toTensor(boxed.image, manifest.detector, channelsFirst: true),
  );
  final kept = nms(
    decodeDetections(out, size, manifest.detectionThreshold),
    manifest.nmsIou,
  );
  final birds = <DetectedBird>[];
  for (final b in kept) {
    final box = unletterbox(
      b,
      boxed.ratio,
      boxed.left,
      boxed.top,
      photo.width,
      photo.height,
    );
    final rect = squareCropRect(box);
    final crop = resizeBicubic(
      cropSquare(photo, rect.left, rect.top, rect.side),
      manifest.classifier.size,
      manifest.classifier.size,
    );
    final probs = classifier(
      toTensor(crop, manifest.classifier, channelsFirst: false),
    );
    final best = argmax(probs);
    final abstained = probs[best] < manifest.abstentionThreshold;
    birds.add(
      DetectedBird(
        left: box.left,
        top: box.top,
        right: box.right,
        bottom: box.bottom,
        score: box.score,
        species: abstained ? 'other' : manifest.classes[best],
        confidence: probs[best],
        abstained: abstained,
      ),
    );
  }
  return DetectionResult(
    photoWidth: photo.width,
    photoHeight: photo.height,
    birds: birds,
  );
}

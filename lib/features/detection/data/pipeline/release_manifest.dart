/// What the app needs from a release's `manifest.json` (contract in
/// `piaf/contracts/README.md`, "Export boundary and app side").
class const ModelInput({
  /// Square side of the input, in pixels.
  required final int size,
  required final double scale,
  required final List<double> mean,
  required final List<double> std,
}) {
  factory ModelInput.fromJson(Map<String, dynamic> json) {
    final width = json['width_px'] as int;
    if (json['height_px'] != width) {
      throw const FormatException('Only square model inputs are supported');
    }
    final norm = json['normalization'] as Map<String, dynamic>;
    List<double> three(String key) => [
      for (final v in norm[key] as List<dynamic>) (v as num).toDouble(),
    ];
    return ModelInput(
      size: width,
      scale: (norm['scale'] as num).toDouble(),
      mean: three('mean'),
      std: three('std'),
    );
  }
}

class const ReleaseManifest({
  required final String version,
  required final List<String> classes,
  required final ModelInput detector,
  required final ModelInput classifier,
  required final double detectionThreshold,
  required final double abstentionThreshold,
  required final double nmsIou,

  /// File name of each role (`detector`, `classifier`).
  required final Map<String, String> files,
}) {
  factory ReleaseManifest.fromJson(Map<String, dynamic> json) {
    final input = json['input'] as Map<String, dynamic>;
    final t = json['thresholds'] as Map<String, dynamic>;
    return ReleaseManifest(
      version: json['version'] as String,
      classes: [for (final c in json['classes'] as List<dynamic>) c as String],
      detector: ModelInput.fromJson(input['detector'] as Map<String, dynamic>),
      classifier: ModelInput.fromJson(
        input['classifier'] as Map<String, dynamic>,
      ),
      detectionThreshold: (t['detection'] as num).toDouble(),
      abstentionThreshold: (t['abstention'] as num).toDouble(),
      // Same default as predict_photo.py: no NMS when a release has none.
      nmsIou: (t['nms_iou'] as num? ?? 1.0).toDouble(),
      files: {
        for (final f in json['files'] as List<dynamic>)
          (f as Map<String, dynamic>)['role'] as String: f['name'] as String,
      },
    );
  }
}

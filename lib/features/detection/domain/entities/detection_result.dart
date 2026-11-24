import 'package:equatable/equatable.dart';

/// One bird the detector found, with the species the classifier gave it.
class const DetectedBird({
  /// Box in pixels of the upright photo: left, top, right, bottom.
  required final double left,
  required final double top,
  required final double right,
  required final double bottom,

  /// Detector score of the box.
  required final double score,

  /// Final species, `other` when the classifier abstained.
  required final String species,

  /// Highest classifier probability, before abstention.
  required final double confidence,

  /// Whether the classifier was not sure enough and answered `other`.
  required final bool abstained,
}) extends Equatable {
  @override
  List<Object?> get props => [
    left,
    top,
    right,
    bottom,
    score,
    species,
    confidence,
    abstained,
  ];
}

/// What the on-device models saw on one photo.
class const DetectionResult({
  /// Size of the upright photo the boxes refer to.
  required final int photoWidth,
  required final int photoHeight,

  /// Most confident first.
  required final List<DetectedBird> birds,

  /// Time of the pipeline itself, without decoding the file.
  final Duration inferenceTime = Duration.zero,

  /// Release of the models that answered, such as `0.1.0`.
  final String modelVersion = '',
}) extends Equatable {
  int get count => birds.length;

  @override
  List<Object?> get props => [
    photoWidth,
    photoHeight,
    birds,
    inferenceTime,
    modelVersion,
  ];
}

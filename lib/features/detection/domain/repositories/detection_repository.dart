import '../../../../core/error/failures.dart';
import '../entities/detection_result.dart';

/// Counts and names the pigeons of a photo, fully on the device.
abstract interface class DetectionRepository {
  /// Loads the models once; [detect] waits for it. Throws [ModelFailure].
  Future<void> load();

  /// Runs the detector and the classifier on the JPEG at [photoPath].
  /// Throws [ModelFailure].
  Future<DetectionResult> detect(String photoPath);
}

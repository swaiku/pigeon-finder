import 'package:pigeon_finder/core/error/failures.dart';
import 'package:pigeon_finder/features/detection/domain/entities/detection_result.dart';
import 'package:pigeon_finder/features/detection/domain/repositories/detection_repository.dart';

/// Answers every photo with [birds] pigeons, or throws [failure] when set.
class FakeDetectionRepository implements DetectionRepository {
  FakeDetectionRepository({this.birds = 1, this.failure});

  int birds;
  Failure? failure;

  @override
  Future<void> load() async {}

  @override
  Future<DetectionResult> detect(String photoPath) async {
    if (failure case final f?) throw f;
    return DetectionResult(
      photoWidth: 100,
      photoHeight: 100,
      birds: [
        for (var i = 0; i < birds; i++)
          const DetectedBird(
            left: 10,
            top: 10,
            right: 50,
            bottom: 50,
            score: 0.9,
            species: 'feral pigeon',
            confidence: 0.95,
            abstained: false,
          ),
      ],
    );
  }
}

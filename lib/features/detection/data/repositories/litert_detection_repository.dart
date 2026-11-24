import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_litert/flutter_litert.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/detection_result.dart';
import '../../domain/repositories/detection_repository.dart';
import '../pipeline/pigeon_pipeline.dart';
import '../pipeline/release_manifest.dart';

/// Runs the release bundled in `assets/models/` with LiteRT, GPU first and
/// CPU if the GPU cannot compile a model. One worker isolate owns both
/// models and does the whole pipeline, so the UI thread only waits.
// shortcut: models are app assets; switch to the OTA release (GET
// /models/latest, SHA-256 checks) when the API serves it.
class LiteRtDetectionRepository implements DetectionRepository {
  LiteRtDetectionRepository({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  static const _dir = 'assets/models';

  final AssetBundle _bundle;
  Future<SendPort>? _worker;

  @override
  Future<void> load() => _ready();

  Future<SendPort> _ready() {
    final worker = _worker ??= _spawn();
    // A failed load is retried on the next call instead of cached.
    worker.ignore();
    return worker.catchError((Object e) {
      _worker = null;
      throw e is ModelFailure ? e : ModelFailure('$e');
    });
  }

  Future<SendPort> _spawn() async {
    final json = await _bundle.loadString('$_dir/manifest.json');
    final manifest = ReleaseManifest.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
    Future<Uint8List> bytes(String role) async =>
        (await _bundle.load('$_dir/${manifest.files[role]}')).buffer
            .asUint8List();
    final ready = ReceivePort();
    await Isolate.spawn(
      _workerMain,
      (
        ready.sendPort,
        json,
        await bytes('detector'),
        await bytes('classifier'),
      ),
      debugName: 'detection',
      onError: ready.sendPort,
    );
    final reply = await ready.first;
    if (reply is! SendPort) throw ModelFailure('Loading the models: $reply');
    debugPrint('Models ${manifest.version} loaded');
    return reply;
  }

  @override
  Future<DetectionResult> detect(String photoPath) async {
    final worker = await _ready();
    final port = ReceivePort();
    worker.send((photoPath, port.sendPort));
    final reply = await port.first;
    if (reply is DetectionResult) return reply;
    throw ModelFailure('Detection: $reply');
  }
}

/// Worker isolate: builds the models, then answers `(path, reply port)`
/// with a [DetectionResult] or an error message.
void _workerMain((SendPort, String, Uint8List, Uint8List) args) {
  final (ready, json, detectorBytes, classifierBytes) = args;
  final ReleaseManifest manifest;
  final CompiledModel detector;
  final CompiledModel classifier;
  try {
    manifest = ReleaseManifest.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
    CompiledModel build(Uint8List bytes, String role) {
      final model = CompiledModel.fromBufferWithConfig(
        bytes,
        onFallback: (e) => debugPrint('$role: GPU unavailable, on CPU: $e'),
      );
      debugPrint('$role on ${model.accelerators}');
      return model;
    }

    detector = build(detectorBytes, 'detector');
    classifier = build(classifierBytes, 'classifier');
  } on Object catch (e) {
    ready.send('$e');
    return;
  }
  final requests = ReceivePort();
  ready.send(requests.sendPort);
  requests.listen((message) {
    final (path, reply) = message as (String, SendPort);
    try {
      final photo = decodePhoto(File(path).readAsBytesSync());
      final watch = Stopwatch()..start();
      final result = runPipeline(
        photo,
        manifest,
        detector: (x) => detector.run([x]).first,
        classifier: (x) => classifier.run([x]).first,
      );
      reply.send(
        DetectionResult(
          photoWidth: result.photoWidth,
          photoHeight: result.photoHeight,
          birds: result.birds,
          inferenceTime: watch.elapsed,
        ),
      );
    } on Object catch (e) {
      reply.send('$e');
    }
  });
}

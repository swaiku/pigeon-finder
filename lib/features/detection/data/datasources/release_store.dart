import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../pipeline/release_manifest.dart';

/// The bytes of one complete release, ready for the models.
class const ReleaseFiles({
  required final String manifestJson,
  required final Uint8List detector,
  required final Uint8List classifier,
  required final String version,

  /// Downloaded from pigeon-api, or bundled in the app.
  required final bool downloaded,
}) {
  String get origin =>
      'release $version, ${downloaded ? 'downloaded' : 'bundled'}';
}

/// Releases downloaded from pigeon-api (`GET /models/latest`, contract in
/// `piaf/contracts/README.md`), kept in [directory]:
///
///     <version>/manifest.json, detector.tflite, classifier.tflite
///     current.json   {"version": "<version>"}
///
/// A release is checked file by file (size and SHA-256) and only then
/// moved in place, so `current.json` always names a complete release. The
/// previous one is kept for rollback.
class ReleaseStore {
  ReleaseStore({
    required this.apiUrl,
    required this.appVersion,
    required this.directory,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Base URL of pigeon-api, such as `https://host/api`. Empty: no download.
  final String apiUrl;
  final Future<String> Function() appVersion;
  final Future<Directory> Function() directory;
  final http.Client _client;

  /// Asks the API for a newer release and installs it, then returns the
  /// installed release; `null` when none was ever installed.
  Future<ReleaseFiles?> resolve() async {
    final root = await directory();
    if (apiUrl.isNotEmpty) {
      try {
        await _update(root);
      } on Object catch (e) {
        // Offline, API down or a bad release: the installed one still works.
        debugPrint('Models: no update ($e)');
      }
    }
    final version = _installed(root);
    if (version == null) return null;
    final folder = Directory('${root.path}/$version');
    final json = File('${folder.path}/manifest.json').readAsStringSync();
    final files = ReleaseManifest.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    ).files;
    Uint8List read(String role) =>
        File('${folder.path}/${files[role]}').readAsBytesSync();
    return ReleaseFiles(
      manifestJson: json,
      detector: read('detector'),
      classifier: read('classifier'),
      version: version,
      downloaded: true,
    );
  }

  Future<void> _update(Directory root) async {
    final installed = _installed(root);
    final uri = Uri.parse('$apiUrl/models/latest').replace(
      queryParameters: {
        'app_version': await appVersion(),
        'current_version': ?installed,
      },
    );
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 15));
    switch (response.statusCode) {
      case 204:
        debugPrint('Models: $installed is up to date');
      case 200:
        await _install(root, response.body, previous: installed);
      default:
        // 409: this app is too old for the release, 503: no valid release.
        throw HttpException('models/latest answered ${response.statusCode}');
    }
  }

  Future<void> _install(
    Directory root,
    String body, {
    required String? previous,
  }) async {
    final manifest = jsonDecode(body) as Map<String, dynamic>;
    final version = _safeName(manifest['version']);
    final staging = Directory('${root.path}/.download-$version');
    if (staging.existsSync()) staging.deleteSync(recursive: true);
    staging.createSync(recursive: true);
    for (final file in manifest['files'] as List<dynamic>) {
      final f = file as Map<String, dynamic>;
      final name = _safeName(f['name']);
      final response = await _client
          .get(Uri.parse(f['url'] as String))
          .timeout(const Duration(minutes: 2));
      final bytes = response.bodyBytes;
      if (response.statusCode != 200) {
        throw HttpException('$name answered ${response.statusCode}');
      }
      if (f['size_bytes'] case final int size when size != bytes.length) {
        throw FormatException('$name: ${bytes.length} bytes, expected $size');
      }
      if (sha256.convert(bytes).toString() !=
          (f['sha256'] as String).toLowerCase()) {
        throw FormatException('$name: SHA-256 mismatch');
      }
      File('${staging.path}/$name').writeAsBytesSync(bytes, flush: true);
    }
    File('${staging.path}/manifest.json').writeAsStringSync(body, flush: true);

    final folder = Directory('${root.path}/$version');
    if (folder.existsSync()) folder.deleteSync(recursive: true);
    staging.renameSync(folder.path);
    final pointer = File('${root.path}/.current.json')
      ..writeAsStringSync(jsonEncode({'version': version}), flush: true);
    pointer.renameSync('${root.path}/current.json');
    debugPrint('Models: installed $version from $apiUrl');

    for (final old in root.listSync().whereType<Directory>()) {
      final name = old.uri.pathSegments.where((s) => s.isNotEmpty).last;
      if (name != version && name != previous) old.deleteSync(recursive: true);
    }
  }

  /// Version named by `current.json`, if its folder is there.
  static String? _installed(Directory root) {
    final pointer = File('${root.path}/current.json');
    if (!pointer.existsSync()) return null;
    try {
      final version = _safeName(
        (jsonDecode(pointer.readAsStringSync())
            as Map<String, dynamic>)['version'],
      );
      return File('${root.path}/$version/manifest.json').existsSync()
          ? version
          : null;
    } on FormatException {
      return null;
    }
  }

  /// A file or folder name from the API, never a path.
  static String _safeName(Object? value) {
    if (value is String &&
        RegExp(r'^[A-Za-z0-9][A-Za-z0-9._+-]*$').hasMatch(value)) {
      return value;
    }
    throw FormatException('Unsafe name in the manifest: $value');
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pigeon_finder/features/detection/data/datasources/release_store.dart';

const api = 'https://piaf.test/api';
final detector = utf8.encode('detector bytes');
final classifier = utf8.encode('classifier bytes');

Map<String, dynamic> manifest(String version, {String? detectorSha}) {
  // The bundled manifest, with this version and files at the test API.
  final m = jsonDecode(
    File('assets/models/manifest.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  Map<String, dynamic> file(String name, List<int> bytes, [String? sha]) => {
    'name': name,
    'role': name.split('.').first,
    'format': 'litert',
    'url': '$api/releases/$version/$name',
    'sha256': sha ?? sha256.convert(bytes).toString(),
    'size_bytes': bytes.length,
  };
  return {
    ...m,
    'version': version,
    'files': [
      file('detector.tflite', detector, detectorSha),
      file('classifier.tflite', classifier),
    ],
  };
}

void main() {
  late Directory root;
  late List<Uri> requests;

  setUp(() {
    root = Directory.systemTemp.createTempSync('releases');
    requests = [];
  });
  tearDown(() => root.deleteSync(recursive: true));

  ReleaseStore store(Map<String, dynamic>? latest) => ReleaseStore(
    apiUrl: api,
    appVersion: () async => '0.4.2',
    directory: () async => root,
    client: MockClient((request) async {
      requests.add(request.url);
      final path = request.url.path;
      if (path.endsWith('/models/latest')) {
        final current = request.url.queryParameters['current_version'];
        return latest == null || current == latest['version']
            ? http.Response('', 204)
            : http.Response(jsonEncode(latest), 200);
      }
      if (path.endsWith('detector.tflite')) {
        return http.Response.bytes(detector, 200);
      }
      if (path.endsWith('classifier.tflite')) {
        return http.Response.bytes(classifier, 200);
      }
      return http.Response('', 404);
    }),
  );

  test('downloads, checks and installs the latest release', () async {
    final release = await store(manifest('0.2.0')).resolve();
    expect(release?.detector, detector);
    expect(release?.classifier, classifier);
    expect(release?.origin, contains('0.2.0'));
    expect(requests.first.queryParameters, {'app_version': '0.4.2'});
    expect(jsonDecode(File('${root.path}/current.json').readAsStringSync()), {
      'version': '0.2.0',
    });
  });

  test('sends the installed version and keeps it when up to date', () async {
    await store(manifest('0.2.0')).resolve();
    requests.clear();
    final release = await store(manifest('0.2.0')).resolve();
    expect(requests.single.queryParameters['current_version'], '0.2.0');
    expect(release?.detector, detector);
  });

  test(
    'keeps the installed release when a file has the wrong SHA-256',
    () async {
      await store(manifest('0.2.0')).resolve();
      final release = await store(manifest('0.3.0', detectorSha: '0' * 64))
          .resolve();
      expect(release?.origin, contains('0.2.0'));
      expect(Directory('${root.path}/0.3.0').existsSync(), isFalse);
    },
  );

  test('keeps the previous release and drops older ones', () async {
    for (final v in ['0.1.0', '0.2.0', '0.3.0']) {
      await store(manifest(v)).resolve();
    }
    final folders = root.listSync().whereType<Directory>().map(
      (d) => d.uri.pathSegments.where((s) => s.isNotEmpty).last,
    );
    expect(folders.toSet(), {'0.2.0', '0.3.0'});
  });

  test('refuses a file name that leaves the release folder', () async {
    final bad = manifest('0.2.0');
    (bad['files'] as List<dynamic>)[0] = {
      ...(bad['files'] as List<dynamic>)[0] as Map<String, dynamic>,
      'name': '../evil.tflite',
    };
    expect(await store(bad).resolve(), isNull);
    expect(File('${root.parent.path}/evil.tflite').existsSync(), isFalse);
  });

  test('returns nothing offline before the first download', () async {
    final offline = ReleaseStore(
      apiUrl: api,
      appVersion: () async => '0.4.2',
      directory: () async => root,
      client: MockClient((_) async => throw const SocketException('offline')),
    );
    expect(await offline.resolve(), isNull);
  });
}

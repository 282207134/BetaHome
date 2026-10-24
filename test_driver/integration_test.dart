import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final sdk = File('android/local.properties')
      .readAsLinesSync()
      .firstWhere((line) => line.startsWith('sdk.dir='))
      .substring(8)
      .replaceAll('\\\\', '\\');
  final adb = '$sdk/platform-tools/adb${Platform.isWindows ? '.exe' : ''}';
  final device = Platform.environment['BETA_DEVICE_ID'];
  final prefix = device == null ? <String>[] : ['-s', device];
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 9742);
  server.listen((request) async {
    final name = request.uri.path.substring(1);
    if (request.method != 'POST' ||
        !RegExp(r'^(light|dark)/[a-z0-9-]+$').hasMatch(name)) {
      request.response.statusCode = 400;
    } else {
      final file = File('docs/screenshots/$name.png');
      await file.parent.create(recursive: true);
      final sink = file.openWrite();
      await for (final chunk in request) {
        sink.add(chunk);
      }
      await sink.close();
      request.response.statusCode = 200;
    }
    await request.response.close();
  });
  final forward = await Process.run(adb, [
    ...prefix,
    'reverse',
    'tcp:9742',
    'tcp:9742',
  ]);
  if (forward.exitCode != 0) throw StateError('${forward.stderr}');
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async => true,
    responseDataCallback: (data) async {
      if (data != null) {
        data.remove('screenshots');
        await writeResponseData(
          data,
          testOutputFilename: 'android-test-results',
          destinationDirectory: 'docs/testing',
        );
      }
      await server.close(force: true);
      await Process.run(adb, [...prefix, 'reverse', '--remove', 'tcp:9742']);
    },
    writeResponseOnFailure: true,
  );
}

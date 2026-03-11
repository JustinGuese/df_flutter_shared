import 'dart:typed_data';

Future<String> getRecordingPath() =>
    throw UnsupportedError('Platform not supported');

Future<Uint8List> readRecordingBytes(String path) =>
    throw UnsupportedError('Platform not supported');

void deleteRecording(String? path) {}

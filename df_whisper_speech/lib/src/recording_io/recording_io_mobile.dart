import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<String> getRecordingPath() async {
  final tempDir = await getTemporaryDirectory();
  return '${tempDir.path}/whisper_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
}

Future<Uint8List> readRecordingBytes(String path) => File(path).readAsBytes();

void deleteRecording(String? path) {
  if (path != null) {
    final file = File(path);
    file.delete().catchError((_) => file);
  }
}

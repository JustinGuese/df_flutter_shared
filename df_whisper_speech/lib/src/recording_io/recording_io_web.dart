import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<String> getRecordingPath() async => '';

Future<Uint8List> readRecordingBytes(String blobUrl) async {
  final response = await web.window.fetch(blobUrl.toJS).toDart;
  final arrayBuffer = await response.arrayBuffer().toDart;
  return arrayBuffer.toDart.asUint8List();
}

void deleteRecording(String? path) {
  if (path != null && path.startsWith('blob:')) {
    web.URL.revokeObjectURL(path);
  }
}

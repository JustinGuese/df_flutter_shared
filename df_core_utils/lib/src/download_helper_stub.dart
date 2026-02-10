import 'dart:typed_data';

/// Stub implementation used on non-web platforms when the web-specific
/// implementation is not available.
Future<void> downloadFileWeb(Uint8List bytes, String fileName) async {
  throw UnsupportedError('Web downloads not supported on this platform');
}


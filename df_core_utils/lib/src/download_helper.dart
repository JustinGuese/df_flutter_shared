import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Conditional import for web
import 'download_helper_stub.dart'
    if (dart.library.html) 'download_helper_web.dart' as web_helper;

/// Cross-platform file download helper.
///
/// On web, triggers a browser download. On mobile/desktop, writes the file
/// to a temporary directory and opens it with the platform handler.
Future<void> downloadFile(Uint8List bytes, String fileName) async {
  if (kIsWeb) {
    await web_helper.downloadFileWeb(bytes, fileName);
  } else {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    await OpenFilex.open(file.path);
  }
}


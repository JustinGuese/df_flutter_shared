import 'dart:html' as html;
import 'dart:typed_data';

/// Web-specific implementation for downloading files in the browser.
Future<void> downloadFileWeb(Uint8List bytes, String fileName) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName);
  anchor.click();
  html.Url.revokeObjectUrl(url);
}


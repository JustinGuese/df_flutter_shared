import 'package:material_ui/material_ui.dart';

/// Parses a comma-separated string of keywords into a list of trimmed keywords.
/// Empty keywords are filtered out.
@Deprecated('Use dfParseKeywords from package:df_ui_widgets.')
List<String> parseKeywords(String value) {
  return value
      .split(',')
      .map((keyword) => keyword.trim())
      .where((keyword) => keyword.isNotEmpty)
      .toList();
}

/// Extracts keywords from a TextEditingController.
/// Returns null if the controller is empty or contains no valid keywords.
@Deprecated('Use dfKeywordsFromController from package:df_ui_widgets.')
List<String>? keywordsFromController(TextEditingController controller) {
  final text = controller.text.trim();
  if (text.isEmpty) return null;
  final parsed = parseKeywords(text);
  return parsed.isEmpty ? null : parsed;
}

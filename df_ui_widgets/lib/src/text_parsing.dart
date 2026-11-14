import 'package:flutter/widgets.dart';

/// Parses a comma-separated string of keywords into trimmed, non-empty items.
///
/// Successor to `parseKeywords` in `df_core_utils` (prefixed so an app that
/// imports both packages has no ambiguous symbol).
List<String> dfParseKeywords(String value) {
  return value
      .split(',')
      .map((keyword) => keyword.trim())
      .where((keyword) => keyword.isNotEmpty)
      .toList();
}

/// Extracts keywords from a [TextEditingController]; null when empty.
List<String>? dfKeywordsFromController(TextEditingController controller) {
  final text = controller.text.trim();
  if (text.isEmpty) return null;
  final parsed = dfParseKeywords(text);
  return parsed.isEmpty ? null : parsed;
}

/// Parses a multi-line summary into bullet points, stripping `•`, `-`, `*`
/// and numbering prefixes. Successor to `parseSummaryPoints`.
List<String> dfParseSummaryPoints(String? summary) {
  if (summary == null) return const [];
  final normalized = summary.replaceAll('•', '\n•');
  return normalized
      .split(RegExp(r'[\r\n]+'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .map(
        (line) =>
            line.replaceFirst(RegExp(r'^([\-\*•]+|\d+[\).]?)\s*'), '').trim(),
      )
      .where((line) => line.isNotEmpty)
      .toList();
}

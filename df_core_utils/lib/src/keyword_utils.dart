import 'package:flutter/material.dart';

/// Parses a comma-separated string of keywords into a list of trimmed keywords.
/// Empty keywords are filtered out.
List<String> parseKeywords(String value) {
  return value
      .split(',')
      .map((keyword) => keyword.trim())
      .where((keyword) => keyword.isNotEmpty)
      .toList();
}

/// Extracts keywords from a TextEditingController.
/// Returns null if the controller is empty or contains no valid keywords.
List<String>? keywordsFromController(TextEditingController controller) {
  final text = controller.text.trim();
  if (text.isEmpty) return null;
  final parsed = parseKeywords(text);
  return parsed.isEmpty ? null : parsed;
}

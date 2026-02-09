/// Parses a multi-line summary string into individual bullet points.
///
/// Accepts strings that use newlines or bullet characters (e.g. •, -, *).
/// Empty lines and bullet prefixes are trimmed.
List<String> parseSummaryPoints(String? summary) {
  if (summary == null) return const [];
  final normalized = summary.replaceAll('•', '\n•');
  final lines = normalized
      .split(RegExp(r'[\r\n]+'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .map((line) {
        final cleaned =
            line.replaceFirst(RegExp(r'^([\-\*\u2022]+|\d+[\).]?)\s*'), '');
        return cleaned.trim();
      })
      .where((line) => line.isNotEmpty)
      .toList();
  return lines;
}

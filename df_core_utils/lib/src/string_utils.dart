/// Truncates [text] to at most [maxChars] characters, cutting at a word boundary
/// (the last whitespace before [maxChars]) and appending [ellipsis].
///
/// If [text.length] <= [maxChars], returns [text] unchanged.
/// If no whitespace is found before [maxChars], cuts at [maxChars] and appends [ellipsis].
/// If [maxChars] <= 0, returns an empty string.
String truncateAtWord(String text, int maxChars, {String ellipsis = '…'}) {
  if (maxChars <= 0) return '';
  if (text.length <= maxChars) return text;
  final cut = text.substring(0, maxChars);
  if (RegExp(r'\s').hasMatch(cut[cut.length - 1]) ||
      RegExp(r'\s').hasMatch(text[maxChars])) {
    return '${cut.trimRight()}$ellipsis';
  }
  final lastSpace = cut.lastIndexOf(RegExp(r'\s'));
  final trimmedCut = lastSpace > 0 ? cut.substring(0, lastSpace) : cut;
  return '${trimmedCut.trimRight()}$ellipsis';
}

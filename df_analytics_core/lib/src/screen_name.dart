import 'package:flutter/widgets.dart';

/// The default [RouteSettings] → screen name mapping: a route name is used as
/// is, a path is normalised with [dfNormaliseScreenName].
String? dfDefaultScreenName(RouteSettings settings) {
  final name = settings.name;
  if (name == null || !name.startsWith('/')) return name;
  return dfNormaliseScreenName(name);
}

/// Collapses id-bearing path segments so a screen report stays readable:
/// `/profiles/42` and `/profiles/99` both become `/profiles/:id`.
///
/// Paths starting with one of [keepPrefixes] are kept verbatim, for the cases
/// where the segment IS the thing being measured (e.g. `/learning/<module>`).
/// Query strings are always dropped.
String? dfNormaliseScreenName(
  String? path, {
  List<String> keepPrefixes = const [],
}) {
  if (path == null || path.isEmpty) return path;
  final clean = path.split('?').first;
  final segments = clean.split('/').where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty) return '/';

  if (keepPrefixes.contains(segments.first)) return clean;

  final normalised = segments.map((s) => _looksLikeId(s) ? ':id' : s);
  return '/${normalised.join('/')}';
}

/// Numeric ids, UUIDs, and Firebase-style opaque handles are all treated as ids.
bool _looksLikeId(String segment) {
  if (RegExp(r'^\d+$').hasMatch(segment)) return true;
  if (RegExp(r'^[0-9a-fA-F-]{16,}$').hasMatch(segment)) return true;
  // Mixed-case alphanumeric handles of document-id length (e.g. Firestore).
  if (segment.length >= 16 && RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(segment)) {
    return true;
  }
  return false;
}

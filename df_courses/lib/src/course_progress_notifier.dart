import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key. Unchanged from when this lived in df_onboarding, so
/// existing installs keep their progress.
const _kPrefsKey = 'learning_progress_v1';

/// Per-item completion state, persisted locally.
///
/// State shape is `Map<courseKey, Set<itemId>>`. Item IDs are built by the
/// renderer as `{courseKey}_{chapterId}` — see [CourseProgressIds].
///
/// This used to live in df_onboarding alongside a second, older course screen.
/// Both wrote to the same preferences key with *different* ID conventions, so
/// a course opened in one screen looked partly complete in the other. There is
/// now one course system and one convention; [migrateLegacyIds] repairs blobs
/// written by the old screen.
class CourseProgressNotifier extends Notifier<Map<String, Set<String>>> {
  @override
  Map<String, Set<String>> build() {
    unawaited(_load());
    return {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPrefsKey);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      state = decoded.map(
        (key, value) => MapEntry(key, Set<String>.from(value as List)),
      );
    } catch (_) {
      // A corrupt blob is not worth crashing over; progress is a convenience,
      // and the next write replaces it.
      state = {};
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.map((k, v) => MapEntry(k, v.toList())));
    await prefs.setString(_kPrefsKey, encoded);
  }

  /// Mark a single item as complete.
  Future<void> markComplete(String courseKey, String itemId) async {
    final current = Map<String, Set<String>>.from(state);
    current[courseKey] = {...(current[courseKey] ?? {}), itemId};
    state = current;
    await _persist();
  }

  /// Mark a single item as incomplete.
  Future<void> markIncomplete(String courseKey, String itemId) async {
    final current = Map<String, Set<String>>.from(state);
    final items = Set<String>.from(current[courseKey] ?? {});
    items.remove(itemId);
    current[courseKey] = items;
    state = current;
    await _persist();
  }

  /// Clear all completed items for a course.
  Future<void> clearCourse(String courseKey) async {
    final current = Map<String, Set<String>>.from(state);
    current.remove(courseKey);
    state = current;
    await _persist();
  }

  /// Fraction of completed items, 0.0–1.0.
  double completionRatio(String courseKey, int total) {
    if (total == 0) return 0.0;
    final done = state[courseKey]?.length ?? 0;
    return (done / total).clamp(0.0, 1.0);
  }

  /// Completed item IDs for a course, for syncing to a backend.
  Set<String> completedItemIds(String courseKey) => state[courseKey] ?? {};

  /// Merge backend IDs into local state, keeping the union.
  Future<void> mergeFromBackend(String courseKey, List<String> itemIds) async {
    final current = Map<String, Set<String>>.from(state);
    current[courseKey] = {...(current[courseKey] ?? {}), ...itemIds};
    state = current;
    await _persist();
  }

  /// Drops IDs written by the retired df_onboarding course screen.
  ///
  /// That screen keyed items by section type and position
  /// (`{courseKey}_{sectionType}_{index}`), which cannot be mapped onto a
  /// chapter ID — the section types no longer exist and the index referred to a
  /// different ordering. Keeping them would leave permanently uncheckable items
  /// inflating every completion ratio, so they are removed rather than
  /// converted. Call once at startup; it is a no-op after the first run.
  Future<void> migrateLegacyIds(Set<String> knownIds) async {
    var changed = false;
    final current = <String, Set<String>>{};
    for (final entry in state.entries) {
      final kept = entry.value.where(knownIds.contains).toSet();
      if (kept.length != entry.value.length) changed = true;
      current[entry.key] = kept;
    }
    if (!changed) return;
    state = current;
    await _persist();
  }
}

/// Builds the item IDs the course player stores.
///
/// One place, so the renderer and any backend sync cannot drift apart — which
/// is exactly how the two old course screens ended up incompatible.
abstract final class CourseProgressIds {
  static String chapter(String courseKey, String chapterId) =>
      '${courseKey}_$chapterId';
}

final courseProgressNotifierProvider =
    NotifierProvider<CourseProgressNotifier, Map<String, Set<String>>>(
      CourseProgressNotifier.new,
    );

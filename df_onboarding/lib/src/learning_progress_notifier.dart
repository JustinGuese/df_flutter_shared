import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kPrefsKey = 'learning_progress_v1';

/// Riverpod Notifier that persists per-item completion state to SharedPreferences.
///
/// State shape: `Map<courseKey, Set<itemId>>` — the set of completed item IDs for each course.
/// Item IDs follow the convention `{courseKey}_{sectionTypeName}_{index}` and are
/// constructed at render time in [LearningCourseScreen].
class LearningProgressNotifier
    extends Notifier<Map<String, Set<String>>> {
  @override
  Map<String, Set<String>> build() {
    _load();
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

  /// Fraction of completed items: 0.0 – 1.0.
  double completionRatio(String courseKey, int total) {
    if (total == 0) return 0.0;
    final done = state[courseKey]?.length ?? 0;
    return (done / total).clamp(0.0, 1.0);
  }

  /// Set of completed item IDs for a course (for syncing to backend).
  Set<String> completedItemIds(String courseKey) => state[courseKey] ?? {};

  /// Merge in a set of item IDs from backend, keeping local union.
  Future<void> mergeFromBackend(String courseKey, List<String> itemIds) async {
    final current = Map<String, Set<String>>.from(state);
    final merged = {...(current[courseKey] ?? {}), ...itemIds};
    current[courseKey] = merged;
    state = current;
    await _persist();
  }
}

final learningProgressNotifierProvider =
    NotifierProvider<LearningProgressNotifier, Map<String, Set<String>>>(
  LearningProgressNotifier.new,
);

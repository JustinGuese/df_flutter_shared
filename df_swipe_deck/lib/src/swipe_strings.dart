import 'package:flutter/foundation.dart';

/// User-facing strings for swipe deck UI components.
///
/// Defaults are English. All placeholder interpolation is done via [fill]
/// or dedicated helper methods.
@immutable
class DfSwipeStrings {
  const DfSwipeStrings({
    this.undoTooltip = 'Undo last swipe',
    this.passTooltip = 'Pass',
    this.openTooltip = 'Read full story',
    this.likeTooltip = 'Like',
    this.passHint = 'Pass',
    this.likeHint = 'Like & save',
    this.progressTemplate = '{current} / {total}',
  });

  /// Tooltip for the undo action button.
  final String undoTooltip;

  /// Tooltip for the pass action button.
  final String passTooltip;

  /// Tooltip for the open/read action button.
  final String openTooltip;

  /// Tooltip for the like action button.
  final String likeTooltip;

  /// Label shown on the left side of the swipe hint.
  final String passHint;

  /// Label shown on the right side of the swipe hint.
  final String likeHint;

  /// Progress readout template with `{current}` and `{total}` placeholders.
  final String progressTemplate;

  /// Replaces `{placeholder}` tokens in [template] with entries in [values].
  static String fill(String template, Map<String, Object?> values) {
    var result = template;
    for (final entry in values.entries) {
      result = result.replaceAll('{${entry.key}}', '${entry.value}');
    }
    return result;
  }

  /// Convenience formatting for [progressTemplate].
  String fillProgress({required int current, required int total}) => fill(
    progressTemplate,
    <String, Object?>{'current': current, 'total': total},
  );
}

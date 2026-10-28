import 'package:in_app_review/in_app_review.dart';

import 'cooldown.dart';

/// Prompts for an in-app store review at high-engagement moments (e.g. streaks),
/// respecting a minimum streak count and a persistent [cooldown].
class DfStoreReviewPrompt {
  static const String defaultKey = 'df_store_review_last_asked';
  static const int defaultMinStreak = 3;
  static const Duration defaultCooldown = Duration(days: 60);

  /// Requests a store review if [streak] >= [minStreak], the [cooldown] has
  /// elapsed since the last ask, and the store review API is available.
  ///
  /// Returns `true` if the review dialog was requested from the platform.
  /// Never throws: errors are swallowed so rating flows never interrupt user tasks.
  static Future<bool> maybeAsk({
    required int streak,
    int minStreak = defaultMinStreak,
    Duration cooldown = defaultCooldown,
    String prefsKey = defaultKey,
    InAppReview? inAppReview,
  }) async {
    if (streak < minStreak) return false;
    try {
      final gate = DfCooldown(key: prefsKey, duration: cooldown);
      if (!await gate.isReady()) return false;

      final review = inAppReview ?? InAppReview.instance;
      if (!await review.isAvailable()) return false;

      await gate.mark();
      await review.requestReview();
      return true;
    } catch (_) {
      return false;
    }
  }
}

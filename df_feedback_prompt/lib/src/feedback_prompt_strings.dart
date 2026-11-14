import 'package:flutter/foundation.dart';

/// User-facing copy for feedback prompt components.
@immutable
class DfFeedbackPromptStrings {
  const DfFeedbackPromptStrings({
    this.primaryButtonLabel = 'Got it',
    this.secondaryButtonLabel = 'Not now',
    this.laterHint =
        'You can always share feedback later from the Profile tab as well.',
  });

  /// German strings constructor.
  const DfFeedbackPromptStrings.de({
    this.primaryButtonLabel = 'Verstanden',
    this.secondaryButtonLabel = 'Nicht jetzt',
    this.laterHint =
        'Du kannst Feedback auch später jederzeit im Profil-Bereich abgeben.',
  });

  final String primaryButtonLabel;
  final String secondaryButtonLabel;
  final String laterHint;
}

/// Alias for [DfFeedbackPromptStrings].
typedef FeedbackPromptStrings = DfFeedbackPromptStrings;

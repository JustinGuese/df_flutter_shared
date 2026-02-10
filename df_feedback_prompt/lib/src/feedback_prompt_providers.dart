import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'feedback_prompt_config.dart';

/// Host apps must override this provider with their own [FeedbackPromptConfig]
/// in [ProviderScope.overrides].
final feedbackPromptConfigProvider = Provider<FeedbackPromptConfig>((ref) {
  throw UnsupportedError(
    'feedbackPromptConfigProvider must be overridden in ProviderScope.overrides',
  );
});


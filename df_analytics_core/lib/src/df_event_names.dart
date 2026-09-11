/// The funnel events shared packages emit. GA4's recommended names are used
/// wherever one exists (`login`, `sign_up`, `tutorial_begin`,
/// `tutorial_complete`), because GA4 builds reports around exactly those.
///
/// Apps define their own domain events next to their own code; only events a
/// shared package fires belong here.
abstract final class DfEvents {
  /// The onboarding carousel was shown (not in help mode).
  static const tutorialBegin = 'tutorial_begin';

  /// An onboarding page became visible. [DfEventParams.pageIndex] is 1-based.
  static const onboardingPageView = 'onboarding_page_view';

  /// The user left onboarding — by finishing it or by skipping it.
  static const tutorialComplete = 'tutorial_complete';

  /// An existing account signed in.
  static const login = 'login';

  /// A new account was created (email sign-up, or a first Google/Apple sign-in).
  static const signUp = 'sign_up';

  /// The user backed out of a Google/Apple sign-in sheet.
  static const authCancelled = 'auth_cancelled';

  /// A sign-in or sign-up attempt failed.
  static const authFailed = 'auth_failed';

  /// The user deleted their account.
  static const accountDeleted = 'account_deleted';

  /// A consent dialog was answered. See [DfEventParams.consentKind].
  static const consentResult = 'consent_result';

  /// The iOS App Tracking Transparency prompt was answered.
  static const attResult = 'att_result';

  /// A coach-mark tour step was shown.
  static const tourStepView = 'tour_step_view';

  /// A coach-mark tour ended — finished or skipped.
  static const tourComplete = 'tour_complete';
}

/// Parameter keys for [DfEvents]. Register the ones you want to break reports
/// down by as event-scoped custom dimensions in GA4 Admin — until then GA4
/// collects them but will not show them in Explorations.
abstract final class DfEventParams {
  /// `email`, `google` or `apple`.
  static const method = 'method';

  /// `login`, `sign_up` or `sso` (Google/Apple, where it is not yet known which).
  static const flow = 'flow';

  /// A machine code (a Firebase auth code or a coarse bucket) — never a message,
  /// which can carry the user's email address.
  static const errorCode = 'error_code';

  static const pageIndex = 'page_index';
  static const pageCount = 'page_count';

  /// 1 when the user skipped, 0 when they reached the end.
  static const skipped = 'skipped';

  /// `ai_data` or `tracking`.
  static const consentKind = 'consent_kind';

  /// 1 when consent was given, 0 when declined.
  static const granted = 'granted';

  static const status = 'status';
  static const stepId = 'step_id';
  static const stepIndex = 'step_index';
  static const stepsSeen = 'steps_seen';
}

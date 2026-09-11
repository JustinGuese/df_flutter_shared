// Guarded on dart.library.js_interop rather than dart.library.html so the web
// implementation is also selected under Wasm.
import 'meta_conversion_tracking_mobile.dart'
    if (dart.library.js_interop) 'meta_conversion_tracking_web.dart'
    as impl;

/// The standard Meta conversion events.
///
/// Meta only recognises a fixed set of event names for ad optimisation, so the
/// decision is which standard event a product action maps to — not what to
/// call it.
enum DfMetaEvent {
  /// Someone engaged: sent a message, started a conversation.
  contact,

  /// Someone showed intent: signed up for a waitlist, started a trial.
  lead,

  /// Someone completed registration.
  completeRegistration,

  /// Someone subscribed.
  subscribe,

  /// Someone paid.
  purchase;

  /// The Pixel (web) event name.
  String get wireName => switch (this) {
    DfMetaEvent.contact => 'Contact',
    DfMetaEvent.lead => 'Lead',
    DfMetaEvent.completeRegistration => 'CompleteRegistration',
    DfMetaEvent.subscribe => 'Subscribe',
    DfMetaEvent.purchase => 'Purchase',
  };

  /// The App Events (mobile SDK) event name.
  ///
  /// Not always [wireName]: the mobile SDK's older standard events carry an
  /// `fb_mobile_` name, and sending the Pixel name instead lands as a *custom*
  /// event that app campaigns cannot optimise for. `Lead` has no mobile
  /// standard event, so it stays a custom event on mobile either way.
  String get appEventName => switch (this) {
    DfMetaEvent.completeRegistration => 'fb_mobile_complete_registration',
    DfMetaEvent.purchase => 'fb_mobile_purchase',
    _ => wireName,
  };
}

/// Reports a conversion to Meta — App Events on mobile, Pixel on web.
///
/// [contentType] names the app's own action (`'diary_entry'`,
/// `'chat_message'`, `'quest_complete'`) and is what distinguishes two
/// conversions of the same [event] in Ads Manager. [registrationMethod]
/// (`'email'`, `'google'`) belongs on [DfMetaEvent.completeRegistration].
///
/// Replaces `trackChatMessageSent()` / `trackDiaryEntryCreated()`, which baked
/// PsychDiary's domain into a package shared by five apps.
void trackMetaConversion(
  DfMetaEvent event, {
  String? contentType,
  String? registrationMethod,
}) {
  impl.trackMetaConversion(
    pixelName: event.wireName,
    appEventName: event.appEventName,
    contentType: contentType,
    registrationMethod: registrationMethod,
  );
}

/// Meta's constraint on custom event names: 1-40 characters, starting with a
/// letter, digit or underscore, and otherwise limited to letters, digits,
/// spaces, underscores and hyphens.
final RegExp _customEventNamePattern = RegExp(r'^[0-9a-zA-Z_][0-9a-zA-Z _-]*$');

/// The longest custom event name Meta accepts.
const int kMetaCustomEventNameMaxLength = 40;

/// Whether [eventName] satisfies Meta's rules for a custom event name.
bool isValidMetaCustomEventName(String eventName) =>
    eventName.isNotEmpty &&
    eventName.length <= kMetaCustomEventNameMaxLength &&
    _customEventNamePattern.hasMatch(eventName);

/// Reports a conversion to Meta under an app-defined [eventName], for signals
/// Meta has no standard event for — retention milestones, activation
/// thresholds. Anything in [DfMetaEvent] belongs on [trackMetaConversion]
/// instead, because only standard events are comparable across advertisers.
///
/// [eventName] must satisfy [isValidMetaCustomEventName]; an invalid name is
/// dropped rather than sent, since Meta discards it silently on its side. In
/// debug builds this asserts instead, so a typo surfaces during development.
///
/// On web only the name reaches the Pixel — [parameters] are dropped, matching
/// [trackMetaConversion]'s handling of `contentType`.
void trackMetaCustomConversion(
  String eventName, {
  Map<String, Object>? parameters,
}) {
  assert(
    isValidMetaCustomEventName(eventName),
    'Invalid Meta custom event name: "$eventName". Must be 1-'
    '$kMetaCustomEventNameMaxLength chars, start with a letter, digit or '
    'underscore, and contain only letters, digits, spaces, underscores and '
    'hyphens.',
  );
  if (!isValidMetaCustomEventName(eventName)) return;
  impl.trackMetaCustomConversion(eventName, parameters);
}

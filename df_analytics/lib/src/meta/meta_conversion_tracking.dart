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

  /// The name Meta expects on the wire.
  String get wireName => switch (this) {
    DfMetaEvent.contact => 'Contact',
    DfMetaEvent.lead => 'Lead',
    DfMetaEvent.completeRegistration => 'CompleteRegistration',
    DfMetaEvent.subscribe => 'Subscribe',
    DfMetaEvent.purchase => 'Purchase',
  };
}

/// Reports a conversion to Meta — App Events on mobile, Pixel on web.
///
/// [contentType] names the app's own action (`'diary_entry'`,
/// `'chat_message'`, `'quest_complete'`) and is what distinguishes two
/// conversions of the same [event] in Ads Manager.
///
/// Replaces `trackChatMessageSent()` / `trackDiaryEntryCreated()`, which baked
/// PsychDiary's domain into a package shared by five apps.
void trackMetaConversion(DfMetaEvent event, {String? contentType}) {
  impl.trackMetaConversion(event.wireName, contentType);
}

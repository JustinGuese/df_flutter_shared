// Guarded on dart.library.js_interop rather than dart.library.html so the web
// implementation is also selected under Wasm.
import 'meta_conversion_tracking_mobile.dart'
    if (dart.library.js_interop) 'meta_conversion_tracking_web.dart'
    as impl;

void trackChatMessageSent() {
  impl.trackChatMessageSent();
}

void trackDiaryEntryCreated() {
  impl.trackDiaryEntryCreated();
}

import 'meta_conversion_tracking_mobile.dart'
    if (dart.library.html) 'meta_conversion_tracking_web.dart' as impl;

void trackChatMessageSent() {
  impl.trackChatMessageSent();
}

void trackDiaryEntryCreated() {
  impl.trackDiaryEntryCreated();
}

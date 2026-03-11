import 'package:facebook_app_events/facebook_app_events.dart';

void trackChatMessageSent() {
  FacebookAppEvents()
      .logEvent(name: 'Contact', parameters: {'content_type': 'chat_message'})
      // ignore_errors: catches async PlatformException if Facebook SDK is not yet initialized
      .catchError((_) {});
}

void trackDiaryEntryCreated() {
  FacebookAppEvents()
      .logEvent(name: 'Lead', parameters: {'content_type': 'diary_entry'})
      .catchError((_) {});
}

import 'package:facebook_app_events/facebook_app_events.dart';

void trackChatMessageSent() {
  try {
    FacebookAppEvents().logEvent(
      name: 'Contact',
      parameters: {'content_type': 'chat_message'},
    );
  } catch (_) {}
}

void trackDiaryEntryCreated() {
  try {
    FacebookAppEvents().logEvent(
      name: 'Lead',
      parameters: {'content_type': 'diary_entry'},
    );
  } catch (_) {}
}

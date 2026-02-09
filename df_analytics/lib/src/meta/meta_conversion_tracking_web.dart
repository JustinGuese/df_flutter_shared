import 'meta_pixel_web.dart' as meta_pixel;

void trackChatMessageSent() {
  meta_pixel.trackMetaPixelContact();
}

void trackDiaryEntryCreated() {
  meta_pixel.trackMetaPixelLead();
}

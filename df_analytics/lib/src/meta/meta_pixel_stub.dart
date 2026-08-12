// Non-web stub for the Meta Pixel. The pixel is a browser-only concept, so
// every entry point is a no-op here.
//
// Keep this file's API in sync with meta_pixel_web.dart — a missing function
// only fails on the platform that selects this stub, so a gap is easy to miss.

void trackMetaPixelEvent(String eventName) {}

void trackMetaPixelCustomEvent(String eventName) {}

void trackMetaPixelInstall() {}

void trackMetaPixelContact() {}

void trackMetaPixelLead() {}

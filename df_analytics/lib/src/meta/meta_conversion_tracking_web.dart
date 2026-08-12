import 'meta_pixel_web.dart' as meta_pixel;

void trackMetaConversion(String eventName, String? contentType) {
  // The Pixel takes the event name directly; contentType is not forwarded
  // because the shared snippet does not carry custom parameters.
  meta_pixel.trackMetaPixelEvent(eventName);
}

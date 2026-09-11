import 'meta_pixel_web.dart' as meta_pixel;

void trackMetaConversion({
  required String pixelName,
  required String appEventName,
  String? contentType,
  String? registrationMethod,
}) {
  // The Pixel takes the event name directly; contentType and
  // registrationMethod are not forwarded because the shared snippet does not
  // carry custom parameters.
  meta_pixel.trackMetaPixelEvent(pixelName);
}

void trackMetaCustomConversion(
  String eventName,
  Map<String, Object>? parameters,
) {
  // trackCustom rather than track: the Pixel rejects names outside Meta's
  // standard set on the `track` method. Parameters are dropped for the same
  // reason contentType is above.
  meta_pixel.trackMetaPixelCustomEvent(eventName);
}

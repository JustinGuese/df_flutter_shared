import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Calls the Meta Pixel `fbq(method, event)` global, if the pixel snippet is
/// present on the page.
///
/// Analytics must never break the app: a missing pixel, a blocked script, or a
/// throwing `fbq` are all treated as "not tracked" rather than propagated.
void _fbq(String method, String event) {
  try {
    if (!globalContext.has('fbq')) return;
    globalContext.callMethod('fbq'.toJS, method.toJS, event.toJS);
  } catch (_) {
    // Deliberately swallowed — see above.
  }
}

/// Fires one of Meta's standard events.
void trackMetaPixelEvent(String eventName) => _fbq('track', eventName);

/// Fires an app-defined event that is not in Meta's standard set.
void trackMetaPixelCustomEvent(String eventName) =>
    _fbq('trackCustom', eventName);

void trackMetaPixelInstall() {
  trackMetaPixelEvent('Lead');
  trackMetaPixelCustomEvent('AppInstall');
}

void trackMetaPixelContact() => trackMetaPixelEvent('Contact');

void trackMetaPixelLead() => trackMetaPixelEvent('Lead');

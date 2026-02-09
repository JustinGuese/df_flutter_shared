// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:js' as js;

void trackMetaPixelInstall() {
  try {
    if (js.context.hasProperty('fbq')) {
      js.context.callMethod('fbq', ['track', 'Lead']);
      js.context.callMethod('fbq', ['trackCustom', 'AppInstall']);
    }
  } catch (e) {}
}

void trackMetaPixelContact() {
  try {
    if (js.context.hasProperty('fbq')) {
      js.context.callMethod('fbq', ['track', 'Contact']);
    }
  } catch (e) {}
}

void trackMetaPixelLead() {
  try {
    if (js.context.hasProperty('fbq')) {
      js.context.callMethod('fbq', ['track', 'Lead']);
    }
  } catch (e) {}
}

import 'package:facebook_app_events/facebook_app_events.dart';

void trackMetaConversion(String eventName, String? contentType) {
  FacebookAppEvents()
      .logEvent(
        name: eventName,
        parameters: <String, Object>{'content_type': ?contentType},
      )
      // Swallowed on purpose: this throws a PlatformException when the Facebook
      // SDK has not finished initialising, and a missed analytics event must
      // never surface as an error in the app.
      .catchError((_) {});
}

void trackMetaCustomConversion(
  String eventName,
  Map<String, Object>? parameters,
) {
  FacebookAppEvents()
      .logEvent(name: eventName, parameters: parameters)
      // Swallowed for the same reason as above.
      .catchError((_) {});
}

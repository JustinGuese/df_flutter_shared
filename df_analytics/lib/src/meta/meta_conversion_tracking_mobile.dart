import 'package:facebook_app_events/facebook_app_events.dart';

void trackMetaConversion({
  required String pixelName,
  required String appEventName,
  String? contentType,
  String? registrationMethod,
}) {
  FacebookAppEvents()
      .logEvent(
        name: appEventName,
        // The SDK's own parameter keys — a plain `content_type` is reported as
        // an unknown custom parameter.
        parameters: <String, Object>{
          FacebookAppEvents.paramNameContentType: ?contentType,
          FacebookAppEvents.paramNameRegistrationMethod: ?registrationMethod,
        },
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

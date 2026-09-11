/// Where analytics events go.
///
/// Shared packages never talk to an analytics SDK. They report through
/// `DfAnalyticsCore`, which forwards to the one sink the app installed at
/// startup — `df_analytics` provides the Firebase + Meta implementation, and an
/// app with its own policy (consent-gated, GA4-only) implements this directly.
///
/// Implementations may assume names and parameters were already validated and
/// normalised by `DfAnalyticsCore`: names match GA4's rules, values are only
/// `String` or `num`, and nulls are gone.
abstract interface class DfAnalyticsSink {
  /// A named event, e.g. `sign_up` with `{method: 'google'}`.
  void track(String name, Map<String, Object> parameters);

  /// The screen the user is now looking at.
  void screenView(String screenName, {String? screenClass});

  /// The signed-in account id, or null after sign-out. A sink decides for
  /// itself whether an id may leave the device — many should ignore it.
  void identify(String? userId);
}

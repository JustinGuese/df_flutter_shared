/// The destination interface for application errors, user identities, and logs.
///
/// Shared packages and application code report errors through [DfErrorReporting],
/// which forwards calls to the installed [DfErrorSink]. Vendor-specific implementations
/// (e.g. Firebase Crashlytics, Sentry) implement this interface.
abstract interface class DfErrorSink {
  /// Records an error [e] with optional stack trace [s], context [reason], and [fatal] flag.
  void recordError(
    Object e,
    StackTrace? s, {
    String? reason,
    bool fatal = false,
  });

  /// Associates subsequent error reports with a user identifier [id], or clears it if `null`.
  void setUser(String? id);

  /// Logs a breadcrumb or diagnostic message [msg] to accompany future error reports.
  void log(String msg);
}

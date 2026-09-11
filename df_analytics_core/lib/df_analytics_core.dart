/// The analytics contract shared by every df_* package and app.
///
/// Packages report through [DfAnalyticsCore]; the app installs one
/// [DfAnalyticsSink] at startup (`df_analytics` does it from
/// `AnalyticsService.initialize()`). Test helpers live in `testing.dart`.
library;

export 'src/df_analytics_core.dart';
export 'src/df_analytics_sink.dart';
export 'src/df_event_names.dart';
export 'src/df_screen_observer.dart';
export 'src/screen_name.dart';

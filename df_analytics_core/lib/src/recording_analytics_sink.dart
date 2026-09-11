import 'df_analytics_core.dart';
import 'df_analytics_sink.dart';

/// One event captured by [RecordingAnalyticsSink].
class RecordedEvent {
  const RecordedEvent(this.name, this.parameters);

  final String name;
  final Map<String, Object> parameters;

  @override
  String toString() => '$name $parameters';
}

/// A sink that remembers everything, for tests.
///
/// ```dart
/// late RecordingAnalyticsSink analytics;
/// setUp(() => analytics = RecordingAnalyticsSink.install());
/// tearDown(DfAnalyticsCore.debugReset);
/// ```
class RecordingAnalyticsSink implements DfAnalyticsSink {
  /// Creates a sink and installs it as `DfAnalyticsCore.sink`.
  factory RecordingAnalyticsSink.install() {
    final sink = RecordingAnalyticsSink();
    DfAnalyticsCore.sink = sink;
    return sink;
  }

  RecordingAnalyticsSink();

  final List<RecordedEvent> events = [];
  final List<String> screens = [];
  final List<String?> identities = [];

  /// The names of [events], in order.
  List<String> get names => [for (final e in events) e.name];

  /// Every recorded event called [name].
  List<RecordedEvent> named(String name) => [
    for (final e in events)
      if (e.name == name) e,
  ];

  @override
  void track(String name, Map<String, Object> parameters) =>
      events.add(RecordedEvent(name, parameters));

  @override
  void screenView(String screenName, {String? screenClass}) =>
      screens.add(screenName);

  @override
  void identify(String? userId) => identities.add(userId);
}

# df_analytics_core

The lightweight, SDK-free analytics contract shared by every `df_*` package and app in DataFortress.

Packages report analytics through `DfAnalyticsCore` without taking any dependency on third-party analytics SDKs (Firebase Analytics, Meta, Amplitude, etc.). The host application installs a single `DfAnalyticsSink` at startup (e.g. from `df_analytics`), and all shared packages automatically emit events through it.

Part of Layer 0 (L0) in the `df_flutter_shared` architecture. Has no dependencies on higher layers.

---

## Installation

```yaml
dependencies:
  df_analytics_core:
    git:
      url: https://github.com/JustinGuese/df_flutter_shared.git
      path: df_analytics_core
      ref: main
```

---

## Core Principles

- **Zero heavy SDK dependencies**: Clean Dart/Flutter contract only.
- **Fail-soft by design**: Never throws into user or UI code. If a sink throws or is not installed, errors are safely logged or dropped.
- **GA4 parameter validation**: Truncates strings exceeding 100 characters and clamps parameter maps to 25 items according to Google Analytics 4 rules.
- **Shared taxonomy (`DfEvents`)**: Standardized event names across onboarding, auth, paywalls, and courses.

---

## Usage

### 1. Recording Events in Packages and Apps

```dart
import 'package:df_analytics_core/df_analytics_core.dart';

// Track a custom event
DfAnalyticsCore.track('feature_used', {
  'mode': 'quick',
  'count': 1,
});

// Track a standard taxonomy event
DfAnalyticsCore.track(DfEvents.paywallView, {
  'placement': 'onboarding',
});

// Identify user
DfAnalyticsCore.identify('user_12345');

// Track screen views
DfAnalyticsCore.screenView('SettingsScreen');
```

### 2. Installing a Sink at App Startup

The app installs a destination sink during initialization:

```dart
import 'package:df_analytics_core/df_analytics_core.dart';

// Installing a custom sink or one provided by df_analytics:
DfAnalyticsCore.installSink(myAnalyticsSink);
```

### 3. Automatic Screen Tracking with `DfScreenObserver`

Attach `DfScreenObserver` to your `MaterialApp` or `GoRouter`:

```dart
MaterialApp(
  navigatorObservers: [
    DfScreenObserver(),
  ],
);
```

Route names and parameters are automatically normalised (IDs and queries stripped).

### 4. Unit and Widget Testing with `testing.dart`

`df_analytics_core/testing.dart` provides `RecordingAnalyticsSink` to assert on tracked events without mocking external SDKs:

```dart
import 'package:df_analytics_core/df_analytics_core.dart';
import 'package:df_analytics_core/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('emits analytics event on button tap', () {
    final sink = RecordingAnalyticsSink();
    DfAnalyticsCore.installSink(sink);

    // Perform action...
    expect(sink.events.any((e) => e.name == DfEvents.signUp), isTrue);
  });
}
```

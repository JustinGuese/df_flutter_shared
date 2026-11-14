# df_error_reporting

Core error reporting contract for [DataFortress.cloud](https://datafortress.cloud/) apps.

Part of Layer 0 (L0) in the `df_flutter_shared` architecture. Contains no vendor-specific crash reporting SDKs (Firebase Crashlytics, Sentry, etc.). Vendor-specific sinks (e.g. `df_error_reporting_firebase`) implement the contract defined here.

---

## What’s included

- **`DfErrorSink`** – Abstract interface defining error recording, user identification, and breadcrumb logging.
- **`DfErrorReporting`** – Static dispatcher and installer that wires Flutter framework errors (`FlutterError.onError`) and root isolate platform errors (`PlatformDispatcher.onError`) to the active sink.
- **`NoopErrorSink`** – Silent, fail-safe sink that safely drops errors without throwing.
- **`RecordingErrorSink`** – In-memory sink for unit and widget tests to assert reported errors, users, and logs.

---

## Usage

### In Application Initialization

```dart
import 'package:df_error_reporting/df_error_reporting.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Install sink (e.g. Firebase Crashlytics sink from df_error_reporting_firebase)
  DfErrorReporting.install(myCrashReportingSink);

  runApp(const MyApp());
}
```

### Manual Error Reporting

```dart
try {
  // ... risky operation
} catch (e, stack) {
  DfErrorReporting.recordError(e, stack, reason: 'Failed to sync data');
}
```

### In Tests

```dart
import 'package:df_error_reporting/testing.dart';

test('reports error on failure', () {
  final sink = RecordingErrorSink.install();
  addTearDown(DfErrorReporting.reset);

  // Trigger action that records error
  expect(sink.errors, hasLength(1));
});
```

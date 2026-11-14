# df_error_reporting_firebase

Firebase Crashlytics error reporting sink for [DataFortress.cloud](https://datafortress.cloud/) apps.

Part of Layer 2 (L2) in the `df_flutter_shared` architecture. Implements the `DfErrorSink` contract from `df_error_reporting` by forwarding errors, user IDs, and breadcrumb logs to `firebase_crashlytics`.

---

## What’s included

- **`DfCrashlyticsErrorSink`** (alias: **`DfFirebaseCrashlyticsSink`**) – `DfErrorSink` implementation for Firebase Crashlytics.
- **`DfCrashlyticsCalls`** – Public seam interface enabling unit testing without initializing native Firebase.

---

## Usage

### In Application Initialization

```dart
import 'package:df_error_reporting/df_error_reporting.dart';
import 'package:df_error_reporting_firebase/df_error_reporting_firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Install Firebase Crashlytics as the active error sink
  DfErrorReporting.install(DfCrashlyticsErrorSink());

  runApp(const MyApp());
}
```

### Manual Error Reporting

Errors reported through `DfErrorReporting` reach Crashlytics automatically:

```dart
try {
  // ... risky operation
} catch (e, stack) {
  DfErrorReporting.recordError(e, stack, reason: 'Sync failed');
}
```

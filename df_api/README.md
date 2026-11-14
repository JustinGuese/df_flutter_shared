# df_api

Core HTTP client abstraction with Bearer token injection, 401 retry, and error mapping for [DataFortress.cloud](https://datafortress.cloud/) apps.

Part of Layer 0 (L0) in the `df_flutter_shared` architecture. Has no dependencies on higher layers.

---

## What’s included

- **DfApiClient** – Configurable `Dio` wrapper that automatically injects a Bearer token via `DfTokenProvider` and performs exactly one token refresh and retry when receiving a 401 response.
- **DfTokenProvider** – `typedef DfTokenProvider = Future<String?> Function()` for asynchronous token acquisition or refresh.
- **DfApiException** – Exception representation with HTTP status code, message, optional error code, and details.
- **mapDioError** – Helper mapping caught `DioException` or any `Object` to `DfApiException`.

---

## Usage

```dart
import 'package:df_api/df_api.dart';

final client = DfApiClient(
  baseUrl: 'https://api.example.com',
  tokenProvider: () async => 'auth-token',
);

try {
  final response = await client.client.get('/v1/profile');
  print(response.data);
} catch (e) {
  final apiError = mapDioError(e);
  print('API error (${apiError.status}): ${apiError.message}');
}
```

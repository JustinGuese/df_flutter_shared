# df_device_id

A simple utility to generate and securely store a persistent unique device UUID.

## Features

- **Persistent**: Generates a UUID once and stores it securely.
- **Secure**: Uses `flutter_secure_storage` to store the device ID.
- **Cross-platform**: Works on all platforms supported by `flutter_secure_storage`.

## Usage

```dart
import 'package:df_device_id/df_device_id.dart';

final deviceIdService = DeviceIdService();
final deviceId = await deviceIdService.getDeviceId();
print('Persistent Device ID: $deviceId');
```

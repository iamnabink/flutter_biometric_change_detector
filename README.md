# flutter_biometric_change_detector

A Flutter plugin to detect changes in biometric authentication status on Android and iOS.

## Inspiration

This package is inspired by discussions and issues from:
- [Flutter GitHub Issue #88848](https://github.com/flutter/flutter/issues/88848#issuecomment-906724327)
- [Flutter GitHub Issue #142788](https://github.com/flutter/flutter/issues/142788)
- [Stack Overflow Question](https://stackoverflow.com/q/77463974/12030116)

## Why This Package?

Detecting biometric changes depends on the platform, and `local_auth` does not provide a direct way to check for biometric updates. Neither iOS nor Android exposes this functionality through existing Flutter plugins, meaning developers must implement native code themselves using platform channels. This package simplifies that process by providing a unified solution for both platforms.

### Android

On Android, when creating a cryptographic key, you can specify that it should be invalidated if new fingerprints are enrolled using `KeyGenParameterSpec.Builder.setInvalidatedByBiometricEnrollment(true)`. However, this only works with keys requiring active authentication. The only way to check if a key is invalidated is by attempting authentication, which may trigger the authentication dialog.

### iOS

On iOS, biometric changes can be detected using the `evaluatedPolicyDomainState` property of `LAContext`. By comparing the current domain state with a previously stored state, we can determine if biometric data has changed.

### Implementation Challenge

Neither of these APIs are directly exposed through existing Flutter plugins. This package provides a Flutter-friendly API by leveraging platform channels with native Swift and Kotlin implementations.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
flutter_biometric_change_detector: ^1.0.1
```

## Usage

Import the package:

```dart
import 'package:flutter_biometric_change_detector/flutter_biometric_change_detector.dart';
```

### Detecting Biometric Changes

Call `detectBiometricChange` to check if biometric authentication has changed:

```dart
final hasChanged = await FlutterBiometricChangeDetector.detectBiometricChange();
```

**Note:** Store the initial `detectBiometricChange` return value in local storage or use it to manage the authentication flow. Once a biometric change is detected, the app will return `false` in subsequent checks unless you track the previous state manually.

## API Reference

```dart
// Enum representing biometric authentication status
enum AuthChangeStatus {
  VALID,    // Authentication is valid and unchanged
  CHANGED,  // Biometric authentication has changed
  INVALID,  // Authentication is invalid
  UNKNOWN   // Status is unknown
}

// Checks biometric authentication status on iOS
Future<AuthChangeStatus?> checkBiometricIOS();

// Checks biometric authentication status on Android
Future<AuthChangeStatus?> checkBiometricAndroid();

// Detects any biometric changes
Future<AuthChangeStatus?> detectBiometricChange();
```

## Contributing

Issues and pull requests are welcome!

- GitHub: [flutter_biometric_change_detector](https://github.com/flutter_biometric_change_detector)
- Me: [Nabraj Khadka](https://github.com/iamnabink)

## License

MIT License

---


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

## How Biometric Change Detection Works

### Android Implementation

The Android implementation uses the Android Keystore system with biometric invalidation:

1. **Key Generation**: Creates an AES encryption key in the Android Keystore with `KeyGenParameterSpec.Builder.setInvalidatedByBiometricEnrollment(true)`. This flag ensures the key becomes invalid when new fingerprints are enrolled or existing ones are removed.

   **About `setInvalidatedByBiometricEnrollment(true)`**:
   - **Introduced in**: Android API level 24 (Android 7.0, Nougat)
   - **Purpose**: Automatically invalidates cryptographic keys when the device's biometric enrollments change
   - **Trigger conditions**: Keys are invalidated when:
     - New fingerprints are added to the device ✅ (works reliably)
     - Existing fingerprints are removed ⚠️ (works but may not be immediate on all devices)
     - All fingerprints are cleared (e.g., factory reset of biometric data) ⚠️ (unreliable)
   - **Behavior**: Once invalidated, the key cannot be used for cryptographic operations and will throw `KeyPermanentlyInvalidatedException`
   - **Combined with**: Usually used alongside `setUserAuthenticationRequired(true)` to create keys that require active biometric authentication
   - **Detection Enhancement**: The plugin performs actual cryptographic operations (`cipher.doFinal()`) to trigger biometric validation, as some Android implementations don't invalidate keys immediately upon fingerprint removal

2. **Enhanced Key Validation**: To reliably detect both biometric additions and removals, the plugin performs a two-step validation:
   - **Step 1**: Initialize a `Cipher` object with the stored key
   - **Step 2**: Perform an actual cryptographic operation (`cipher.doFinal()`) to trigger biometric validation
   - **Results**:
     - If both steps succeed: Biometric status is `VALID`
     - If `KeyPermanentlyInvalidatedException` is thrown: Biometric status is `CHANGED`
     - If `InvalidKeyException` occurs: Biometric status is `INVALID`
   - **Why two steps?**: Some Android implementations don't immediately invalidate keys when fingerprints are removed. The cryptographic operation forces the system to check biometric validity.

3. **Key Regeneration**: When biometric changes are detected, the old key is deleted and a new key is generated with the same parameters to prepare for future checks.

**Note**: This approach requires API level 23+ (Android 6.0) and only works with fingerprint authentication. Face unlock and other biometric methods may not trigger key invalidation.

### iOS Implementation

The iOS implementation uses LocalAuthentication framework's domain state tracking:

1. **Domain State Retrieval**: Uses `LAContext.evaluatedPolicyDomainState` to get the current biometric policy domain state, which represents the current set of enrolled biometric data.

2. **State Comparison**: Converts the domain state to base64 and compares it with a previously stored value in `UserDefaults`:
   - If no previous state exists (first run): Status is `VALID`
   - If states match: Status is `VALID`
   - If states differ: Status is `CHANGED`

3. **State Persistence**: Updates the stored domain state for future comparisons. This allows the plugin to detect when users add, remove, or change their biometric data (Touch ID or Face ID).

**Note**: This method works for both Touch ID and Face ID, and doesn't require actual biometric authentication prompts during the check.

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


import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_biometric_change_detector/status_enum.dart';

import 'flutter_biometric_change_detector_platform_interface.dart';

/// An implementation of [FlutterBiometricChangeDetectorPlatform] that uses method channels.
class MethodChannelFlutterBiometricChangeDetector
    extends FlutterBiometricChangeDetectorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('BIOMETRIC_CHANGE');

  @override
  Future<AuthChangeStatus?> detectBiometricChange() async {
    try {
      return Platform.isIOS
          ? await checkBiometricIOS()
          : await checkBiometricAndroid();
    } catch (e) {
      if (kDebugMode) print("Error checking biometric status: ${e.toString()}");
      return AuthChangeStatus.UNKNOWN;
    }
  }

  @override
  Future<AuthChangeStatus?> checkBiometricIOS() async {
    try {
      final String result =
          await methodChannel.invokeMethod('checkBiometricChange');
      // Map result to enum
      switch (result) {
        case "biometricChanged":
          return AuthChangeStatus.CHANGED;
        case "biometricValid":
          return AuthChangeStatus.VALID;
        default:
          return AuthChangeStatus.INVALID;
      }
    } on PlatformException catch (e) {
      if (kDebugMode) print("Error checking biometric status: ${e.message}");
      return AuthChangeStatus.INVALID;
    }
  }

  /// For Android (Only Fingerprint )
  /// If user does not update Finger then Biometric Status will be AuthLocalStatus.valid
  @override
  Future<AuthChangeStatus?> checkBiometricAndroid() async {
    try {
      final result = await methodChannel.invokeMethod('checkBiometricChange');
      return result == 'biometricValid' ? AuthChangeStatus.VALID : null;
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'biometricChanged':
          return AuthChangeStatus.CHANGED;
        case 'biometricInvalid':
          return AuthChangeStatus.INVALID;
        default:
          return null;
      }
    } on MissingPluginException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }
}

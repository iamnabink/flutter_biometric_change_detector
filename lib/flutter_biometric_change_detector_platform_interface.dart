import 'package:flutter_biometric_change_detector/status_enum.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_biometric_change_detector_method_channel.dart';

abstract class FlutterBiometricChangeDetectorPlatform
    extends PlatformInterface {
  /// Constructs a FlutterBiometricChangeDetectorPlatform.
  FlutterBiometricChangeDetectorPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterBiometricChangeDetectorPlatform _instance =
      MethodChannelFlutterBiometricChangeDetector();

  /// The default instance of [FlutterBiometricChangeDetectorPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterBiometricChangeDetector].
  static FlutterBiometricChangeDetectorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterBiometricChangeDetectorPlatform] when
  /// they register themselves.
  static set instance(FlutterBiometricChangeDetectorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Method to check if biometric authentication is available and valid on iOS devices.
  /// Returns an AuthChangeStatus based on the biometric status.
  Future<AuthChangeStatus?> checkBiometricIOS();

  /// Method to check if biometric authentication is available and valid on Android devices.
  /// Returns an AuthChangeStatus based on the biometric status.
  Future<AuthChangeStatus?> checkBiometricAndroid();

  /// Method to detect any changes in biometric authentication.
  /// Returns an AuthChangeStatus to reflect if biometric credentials have changed.
  Future<AuthChangeStatus?> detectBiometricChange();
}

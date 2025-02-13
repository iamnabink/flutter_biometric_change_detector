import 'package:flutter_biometric_change_detector/status_enum.dart';

import 'flutter_biometric_change_detector_platform_interface.dart';

//
//  NotificationData.swift
//  FlutterBiometricChangeDetector
//
//  Created by Nabraj Khadka on 12/02/2025.
//
class FlutterBiometricChangeDetector {
  FlutterBiometricChangeDetector._internal();

  static Future<AuthChangeStatus?> checkBiometric() {
    return FlutterBiometricChangeDetectorPlatform.instance
        .detectBiometricChange();
  }

  /// iOS only
  static Future<AuthChangeStatus?> checkBiometricIOS() {
    return FlutterBiometricChangeDetectorPlatform.instance.checkBiometricIOS();
  }

  /// Android only
  static Future<AuthChangeStatus?> checkBiometricAndroid() {
    return FlutterBiometricChangeDetectorPlatform.instance
        .checkBiometricAndroid();
  }
}

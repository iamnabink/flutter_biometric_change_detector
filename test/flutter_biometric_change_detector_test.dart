import 'package:flutter_biometric_change_detector/status_enum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_biometric_change_detector/flutter_biometric_change_detector.dart';
import 'package:flutter_biometric_change_detector/flutter_biometric_change_detector_platform_interface.dart';
import 'package:flutter_biometric_change_detector/flutter_biometric_change_detector_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterBiometricChangeDetectorPlatform
    with MockPlatformInterfaceMixin
    implements FlutterBiometricChangeDetectorPlatform {
  @override
  Future<AuthChangeStatus?> checkBiometricAndroid() {
    throw UnimplementedError();
  }

  @override
  Future<AuthChangeStatus?> checkBiometricIOS({String token = ''}) {
    throw UnimplementedError();
  }

  @override
  Future<String> getTokenBiometric() {
    throw UnimplementedError();
  }

  @override
  Future<AuthChangeStatus?> detectBiometricChange({String? token}) {
    throw UnimplementedError();
  }
}

void main() {
  final FlutterBiometricChangeDetectorPlatform initialPlatform =
      FlutterBiometricChangeDetectorPlatform.instance;

  test('$MethodChannelFlutterBiometricChangeDetector is the default instance',
      () {
    expect(initialPlatform,
        isInstanceOf<MethodChannelFlutterBiometricChangeDetector>());
  });

  test('getToken', () async {
    expect(FlutterBiometricChangeDetector.checkBiometricAndroid(), true);
  });
}

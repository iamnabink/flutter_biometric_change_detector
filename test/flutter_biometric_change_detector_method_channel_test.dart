import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_biometric_change_detector/flutter_biometric_change_detector_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFlutterBiometricChangeDetector platform = MethodChannelFlutterBiometricChangeDetector();
  const MethodChannel channel = MethodChannel('BIOMETRIC_CHANGE');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('checkBiometricChange', () async {
    expect(await platform.checkBiometricAndroid(), 'biometricChanged');
  });
}

//
//  NotificationData.swift
//  FlutterBiometricChangeDetectorPlugin
//
//  Created by Nabraj Khadka on 12/02/2025.
//

import Flutter
import UIKit
import LocalAuthentication

public class FlutterBiometricChangeDetectorPlugin: NSObject, FlutterPlugin {

    /// Registers the plugin with the Flutter app by creating a method channel
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channelName = "BIOMETRIC_CHANGE"
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let instance = FlutterBiometricChangeDetectorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    /// Handles method calls from Flutter
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "checkBiometricChange":
            self.checkForBiometricChanges { status in
                result(status)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Checks for biometric changes and returns a status message
    func checkForBiometricChanges(complete: @escaping (String) -> Void) {
        let context = LAContext()
        var authError: NSError?

        let storeKeyName = "biometric_domain_state"

        // Check if biometrics are available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) else {
            complete("unknown")
            return
        }

        // Retrieve biometric domain state
        if let biometricData = context.evaluatedPolicyDomainState {
            let base64Data = biometricData.base64EncodedString()

            // Get previously stored biometric token
            let defaults = UserDefaults.standard
            let savedToken = defaults.string(forKey: storeKeyName)

            // Compare new token with saved token
            let biometricChanged = (savedToken != nil && savedToken != base64Data)

            // Update stored biometric token
            defaults.set(base64Data, forKey: storeKeyName)

            // Return appropriate response
            complete(biometricChanged ? "biometricChanged" : "biometricValid")
        } else {
            complete("unknown")
        }
    }
}
//Predefined LAError Codes from LocalAuthentication
//Error Code	Enum Value	Meaning
//-6	LAError.biometryNotAvailable	The device does not support biometric authentication.
//-7	LAError.biometryNotEnrolled	The user has not set up biometric authentication.
//-8	LAError.biometryLockout	Too many failed attempts, requiring a passcode reset.
//-1	LAError.authenticationFailed	The user failed authentication.
//-2	LAError.userCancel	The user canceled the authentication prompt.
//-3	LAError.userFallback	The user chose to enter a password instead of biometrics.
//-4	LAError.systemCancel	The system canceled authentication (e.g., another app moved to the foreground).
//-9	LAError.appCancel	The app canceled authentication.
//-10	LAError.invalidContext	The LAContext is invalid or was previously released.
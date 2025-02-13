//
//  NotificationData.swift
//  FlutterBiometricChangeDetectorPlugin
//
//  Created by Nabraj Khadka on 12/02/2025.
//
// Enum representing the possible states of an authentication change.
enum AuthChangeStatus {
  VALID,    // Indicates that the authentication is valid and unchanged.
  CHANGED,  // Indicates that the authentication has been changed.
  INVALID,  // Indicates that the authentication is invalid.
  UNKNOWN   // Indicates that the status of the authentication change is unknown.
}

//
//  NotificationData.swift
//  FlutterBiometricChangeDetectorPlugin
//
//  Created by Nabraj Khadka on 12/02/2025.
//
// Enum representing the possible states of an authentication change.
enum AuthChangeStatus {
  // ignore: constant_identifier_names
  VALID, // Indicates that the authentication is valid and unchanged.
  // ignore: constant_identifier_names
  CHANGED, // Indicates that the authentication has been changed.
  // ignore: constant_identifier_names
  INVALID, // Indicates that the authentication is invalid.
  // ignore: constant_identifier_names
  UNKNOWN // Indicates that the status of the authentication change is unknown.
}

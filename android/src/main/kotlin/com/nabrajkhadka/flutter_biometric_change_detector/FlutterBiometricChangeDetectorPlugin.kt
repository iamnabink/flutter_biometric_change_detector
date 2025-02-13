//
//  NotificationData.swift
//  FlutterBiometricChangeDetectorPlugin
//
//  Created by Nabraj Khadka on 12/02/2025.
//
package com.nabrajkhadka.flutter_biometric_change_detector

import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyPermanentlyInvalidatedException

import android.security.keystore.KeyProperties
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.biometric.BiometricPrompt
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.security.InvalidKeyException
import java.security.Key
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey

/** FlutterBiometricChangeDetectorPlugin */
class FlutterBiometricChangeDetectorPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var keyStore: KeyStore? = null
  private val KEY_NAME = "BIOMETRIC_CHANGE"
  private var biometricPrompt: BiometricPrompt? = null


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, KEY_NAME)
    channel.setMethodCallHandler(this)
  }

  @RequiresApi(Build.VERSION_CODES.N)
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "checkBiometricChange") {
      checkBiometricChange(result)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  @RequiresApi(Build.VERSION_CODES.N)
  private fun checkBiometricChange( result: Result) {
    val cipher: Cipher = getCipher()
    val secretKey: SecretKey = getSecretKey()

    try {
      cipher.init(Cipher.ENCRYPT_MODE, secretKey)

      result.success("biometricValid")

    } catch (e: KeyPermanentlyInvalidatedException) {

      result.error("biometricChanged",
        "Yes your hand has been changed, please login to activate again",e.toString())

    } catch (e: InvalidKeyException) {
      e.printStackTrace() //todo: print only in debug mode
      result.error("biometricInvalid","Invalid biometric",e.toString())
    }
    //Title require
    val promptInfo = BiometricPrompt.PromptInfo.Builder().setTitle("Biometric").setDescription("Check Biometric").setNegativeButtonText("OK").build()

    try {
      cipher.init(Cipher.ENCRYPT_MODE, secretKey)
      biometricPrompt?.authenticate(promptInfo, BiometricPrompt.CryptoObject(cipher))
    } catch (e: KeyPermanentlyInvalidatedException) {
      keyStore?.deleteEntry(KEY_NAME)
      if (getCurrentKey(KEY_NAME) == null) {
        generateSecretKey(KeyGenParameterSpec.Builder(KEY_NAME,
          KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT).setBlockModes(KeyProperties.BLOCK_MODE_CBC)
          .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_PKCS7)
          .setUserAuthenticationRequired(true) // Invalidate the keys if the user has registered a new biometric
          .setInvalidatedByBiometricEnrollment(true).build())
      }

    }
  }
  fun getCurrentKey(keyName: String): Key? {
    keyStore?.load(null)
    return keyStore?.getKey(keyName, null)
  }

  @RequiresApi(Build.VERSION_CODES.N)
  fun getSecretKey(): SecretKey {
    try {
      keyStore = KeyStore.getInstance("AndroidKeyStore")
    } catch (e: Exception) {
      e.printStackTrace() //todo: print only in debug mode
    }
    var keyGenerator: KeyGenerator? = null
    try {
      keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore")
    } catch (e: Exception) {
      e.printStackTrace() //todo: print only in debug mode
    }
    try {
      if (getCurrentKey(KEY_NAME) == null) {
        keyGenerator!!.init(
          KeyGenParameterSpec.Builder(KEY_NAME,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT).setBlockModes(
            KeyProperties.BLOCK_MODE_CBC)
            .setUserAuthenticationRequired(true).setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_PKCS7)
            .setInvalidatedByBiometricEnrollment(true)
            .build())
        keyGenerator.generateKey()
      }

    } catch (e: Exception) {
      e.printStackTrace() //todo: print only in debug mode
    }
    return keyStore?.getKey(KEY_NAME, null) as SecretKey
  }

  @RequiresApi(Build.VERSION_CODES.M)
  fun getCipher(): Cipher {
    return Cipher.getInstance(
      KeyProperties.KEY_ALGORITHM_AES + "/"
              + KeyProperties.BLOCK_MODE_CBC + "/"
              + KeyProperties.ENCRYPTION_PADDING_PKCS7)
  }
  @RequiresApi(Build.VERSION_CODES.M)
  fun generateSecretKey(keyGenParameterSpec: KeyGenParameterSpec) {
    val keyGenerator = KeyGenerator.getInstance(
      KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore")
    keyGenerator.init(keyGenParameterSpec)
    keyGenerator.generateKey()
  }
}

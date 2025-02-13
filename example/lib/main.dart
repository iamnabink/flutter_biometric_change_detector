//
//  NotificationData.swift
//  FlutterBiometricChangeDetectorPlugin
//
//  Created by Nabraj Khadka on 12/02/2025.
//
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_biometric_change_detector/flutter_biometric_change_detector.dart';
import 'package:flutter_biometric_change_detector/status_enum.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TestHomePage(),
    );
  }
}

class TestHomePage extends StatefulWidget {
  const TestHomePage({super.key});

  @override
  State<TestHomePage> createState() => _TestHomePageState();
}

class _TestHomePageState extends State<TestHomePage>
    with WidgetsBindingObserver {
   bool? _hasChanged;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      checkBiometric();
    });
    super.initState();
  }

  checkBiometric() async {
    final hasChanged = await FlutterBiometricChangeDetector.checkBiometric();
    setState(() {
      _hasChanged = hasChanged == AuthChangeStatus.CHANGED;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkBiometric();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello World'),
      ),
      body: Center(child: Text('Has changed $_hasChanged')),
    );
  }
}

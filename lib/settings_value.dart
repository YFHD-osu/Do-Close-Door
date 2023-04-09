import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class Settings {
  final Future<SharedPreferences> preferences = SharedPreferences.getInstance();
  late ValueNotifier<bool> isDark;
  late Directory? appPath;
  late ValueNotifier<bool> permsEnough;
  
  Future<void> initState () async {
    final SharedPreferences prefs = await preferences;
    permsEnough =  ValueNotifier<bool>(
      // Picture In Picture Permission
      await Permission.systemAlertWindow.isGranted &&
      // Location Permission
      await Permission.location.isGranted &&
      // Camera Permissions
      await Permission.microphone.isGranted &&
      await Permission.camera.isGranted &&
      // Bluetooth Permission
      await Permission.bluetoothConnect.status.isGranted &&
      await Permission.bluetoothAdvertise.status.isGranted &&
      await Permission.bluetoothScan.status.isGranted
    );
    isDark = ValueNotifier<bool>(prefs.getBool('isDark') ?? false);
    appPath = await getExternalStorageDirectory();
  }
}
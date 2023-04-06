import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'page/permission_page.dart';
import 'page/home_page.dart';
import 'theme.dart' ;
import 'dart:io';
import 'foreground.dart';

late ValueNotifier<bool> isLight;
late ValueNotifier<bool> permsEnough;
late Directory? appPath;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  permsEnough =  ValueNotifier<bool>( // @
    await Permission.bluetoothConnect.status.isGranted &&
    await Permission.bluetoothAdvertise.status.isGranted &&
    await Permission.bluetoothScan.status.isGranted
  );
  isLight = ValueNotifier<bool>(
    false
  );
  appPath = await getExternalStorageDirectory();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
    isLight.addListener(() => setState(() {})); // Detect theme change
    permsEnough.addListener(() => setState(() {})); // Detect if permission is enough
  }
  
  @override
  void dispose() {
    super.dispose();
    isLight.removeListener(() {});
    permsEnough.removeListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => permsEnough.value ? const MyHomePage() : const PermissionPage()
      },
      title: '監聽攝影機',
      theme: isLight.value ? AppThemeData.lightMode : AppThemeData.darkMode,
    );
  }
}




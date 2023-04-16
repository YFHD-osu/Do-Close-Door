import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'page/permission_page.dart';
import 'page/home_page.dart';
import 'settings_value.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  await settings.initState();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  @override
  void initState() {
    super.initState();
    settings.isDark.addListener(() => setState(() {})); // Detect theme change
    settings.permsEnough.addListener(() => setState(() {})); // Detect if permission is enough
  }
  
  @override
  void dispose() {
    super.dispose();
    settings.isDark.removeListener(() {});
    settings.permsEnough.removeListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '監聽攝影機',
      initialRoute: '/',
      navigatorKey: settings.navigatorKey,
      theme: settings.isDark.value ? AppThemeData.darkMode : AppThemeData.lightMode,
      routes: {
        '/' : (context) => PiPSwitcher(
          childWhenDisabled: settings.permsEnough.value ? const MyHomePage() : const PermissionPage(),
          childWhenEnabled: const PiPCameraPreview(), 
        )
      }
    
    );
  }
}
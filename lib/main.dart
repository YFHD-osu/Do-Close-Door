import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'page/permission_page.dart';
import 'page/home_page.dart';
import 'settings_value.dart';
import 'foreground.dart';
import 'theme.dart';

final Settings settings = Settings();
final floating = Floating();

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
      theme: settings.isDark.value ? AppThemeData.darkMode : AppThemeData.lightMode,
      home: WillStartForegroundTask(
         onWillStart: () async {
           // Return whether to start the foreground service.
           return true;
         },
         androidNotificationOptions: AndroidNotificationOptions(
           channelId: 'notification_channel_id',
           channelName: '背景運作通知',
           channelDescription: '攝影機鏡頭的後台程式',
           channelImportance: NotificationChannelImportance.LOW,
           priority: NotificationPriority.LOW,
           iconData: const NotificationIconData(
             resType: ResourceType.mipmap,
             resPrefix: ResourcePrefix.ic,
             name: 'launcher',
           ),
         ),
         iosNotificationOptions: const IOSNotificationOptions(
           showNotification: true,
           playSound: false,
         ),
         foregroundTaskOptions: const ForegroundTaskOptions(
           interval: 5000,
           autoRunOnBoot: false,
           allowWifiLock: false,
         ),
         notificationTitle: '攝影機客戶端正在執行',
         notificationText: '點擊此處已返回App',
         callback: startCallback,
         child: 
          PiPSwitcher(
            childWhenDisabled: settings.permsEnough.value ? const MyHomePage() : const PermissionPage(),
            childWhenEnabled: const PiPCameraPreview(), 
          ),
      )
    );
  }
}
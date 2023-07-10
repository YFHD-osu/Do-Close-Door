import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:isolate';
import 'dart:io';

final Settings settings = Settings();

@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;

    // You can use the getData function to get the stored data.
    final customData =
      await FlutterForegroundTask.getData<String>(key: 'customData');
    print('customData: $customData');
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
      notificationTitle: '監聽攝影機在後台運作中',
      notificationText: '為保持對相機的連續調用，必須運作後台程式',
    );

    // Send data to the main isolate.
    sendPort?.send(_eventCount);
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    //print('onButtonPressed >> $id');
    settings.stopForegroundTask();
  }

  @override
  void onNotificationPressed() {
    // Called when the notification itself on the Android platform is pressed.
    //
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // this function to be called.

    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }
}

class Settings {
  final Future<SharedPreferences> preferences = SharedPreferences.getInstance();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late ValueNotifier<bool> isServiceRunning;
  late ValueNotifier<bool> permsEnough;
  late ValueNotifier<bool> isDark;
  late Directory? appPath;
  ReceivePort? _receivePort;

  void initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: Colors.orange,
        ),
        buttons: [
          const NotificationButton(id: 'exitButton', text: '結束'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<bool> startForegroundTask() async {
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // onNotificationPressed function to be called.
    //
    // When the notification is pressed while permission is denied,
    // the onNotificationPressed function is not called and the app opens.
    //
    // If you do not use the onNotificationPressed or launchApp function,
    // you do not need to write this code.
    if (!await FlutterForegroundTask.canDrawOverlays) {
      final isGranted =
          await FlutterForegroundTask.openSystemAlertWindowSettings();
      if (!isGranted) {
        print('SYSTEM_ALERT_WINDOW permission denied!');
        return false;
      }
    }

    // Register the receivePort before starting the service.
    final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
    final bool isRegistered = _registerReceivePort(receivePort);
    if (!isRegistered) {
      print('Failed to register receivePort!');
      return false;
    }

    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }
  }

  Future<bool> stopForegroundTask() {
    return FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? newReceivePort) {
    if (newReceivePort == null) {
      return false;
    }

    closeReceivePort();

    _receivePort = newReceivePort;
    _receivePort?.listen((message) {
      if (!isServiceRunning.value) stopForegroundTask();
      if (message is int) {
        // print('eventCount: $message');
      } else if (message is String) {
        if (message == 'onNotificationPressed') {
          navigatorKey.currentState?.pushNamed('/');
        }
      } else if (message is DateTime) {
        print('timestamp: ${message.toString()}');
      }
    });

    return _receivePort != null;
  }

  void closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  T? ambiguate<T>(T? value) => value;

  Future<void> initState () async {
    final SharedPreferences prefs = await preferences;
    isServiceRunning = ValueNotifier<bool>(true);
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

    initForegroundTask();
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) async {
      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
    });
    await startForegroundTask();
  }

  Future<void> dispose () async {
    closeReceivePort();
  }
}


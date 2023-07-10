import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './../settings_value.dart';

bool isServiceSetting = false;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, toolbarHeight: 0),
      body: const Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.settings, size: 80),
              Text("設定", style: TextStyle(fontSize: 60))
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(child: SettingsColumn())
          )
        ]
      ) 
    );
  }
}

class SettingsColumn extends StatefulWidget {
  const SettingsColumn({super.key});

  @override
  State<SettingsColumn> createState() => _SettingsColumnState();
}

class _SettingsColumnState extends State<SettingsColumn> {
  final wakeLock = const MethodChannel('flutter.dev/PowerManager/Wakelock');
  bool? isWakeLock;

  @override
  void initState() {
    Future.delayed(const Duration(microseconds: 0)).then((value) async {
      isWakeLock = await wakeLock.invokeMethod("isHeld");
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          child: Container(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            width: MediaQuery.of(context).size.width-20,
            height: 50,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Icon(settings.isDark.value ? Icons.nightlight : Icons.sunny, size: 35),
                const SizedBox(width:10),
                const Text("深色主題", style: TextStyle(fontSize: 20)),
                const Spacer(),
                Switch(
                  value: settings.isDark.value,
                  onChanged: (value) async {
                    settings.isDark.value = !settings.isDark.value;
                    final SharedPreferences prefs = await settings.preferences;
                    prefs.setBool("isDark", settings.isDark.value);
                    setState(() {});
                  }
                )
              ],
            )
          ),
          onTap: () => setState(() => settings.isDark.value = !settings.isDark.value),
        ),
        InkWell(
          child: Container(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            width: MediaQuery.of(context).size.width-20,
            height: 50,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Icon(isWakeLock==true ? Icons.lock : Icons.lock_open, size: 35),
                const SizedBox(width:10),
                const Text("喚醒鎖定", style: TextStyle(fontSize: 20)),
                const Spacer(),
                Switch(
                  value: (isWakeLock==null) ? false : isWakeLock!,
                  onChanged: (isWakeLock == null) ? null : (value) async {
                    if (value) {
                      await wakeLock.invokeMethod("acquire");
                    }else {
                      await wakeLock.invokeMethod("release");
                    }
                    setState(() => isWakeLock = value);
                  }
                )
              ],
            )
          ),
          onTap: () => setState(() => isWakeLock = !isWakeLock!),
        ),
        InkWell(
          onTap: (isServiceSetting) ? null : () async {
            setState(() => isServiceSetting = true);
            if (!settings.isServiceRunning.value) {
              await settings.startForegroundTask();
            } else {
              await settings.stopForegroundTask();
            }
            isServiceSetting = false;
            setState(() => settings.isServiceRunning.value = !settings.isServiceRunning.value);
          },
          child: Container(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            width: MediaQuery.of(context).size.width-20,
            height: 50,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.android , size: 35),
                const SizedBox(width:10),
                const Text("前檯服務", style: TextStyle(fontSize: 20)),
                const Spacer(),
                Switch(
                  value: settings.isServiceRunning.value,
                  onChanged: (isServiceSetting) ? null :(value) async {
                    setState(() => isServiceSetting = true);
                    if (value) {
                      await settings.startForegroundTask();
                    } else {
                      await settings.stopForegroundTask();
                    }
                    isServiceSetting = false;
                    setState(() => settings.isServiceRunning.value = value);
                  }
                )
              ],
            )
          )
        )
      ],
    );
  }
}
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:doclosedoor/main.dart';

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
      body: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Icon(Icons.settings, size: 80),
              Text("設定", style: TextStyle(fontSize: 60))
            ],
          ),
          const SizedBox(height: 10),
          const Expanded(
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
        )
      ],
    );
  }
}
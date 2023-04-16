import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import './../settings_value.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({Key? key}) : super(key: key);

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  bool bluetoothStatus = false, cameraStatus = false, locationStatus = false, overlayStatus = false;

  bool isAllGranted() => 
    settings.permsEnough.value = bluetoothStatus && cameraStatus && locationStatus && overlayStatus;
  
  void asyncMethod() async{
    bluetoothStatus =
      await Permission.bluetoothConnect.status.isGranted &&
      await Permission.bluetoothAdvertise.status.isGranted &&
      await Permission.bluetoothScan.status.isGranted;
    cameraStatus = 
      await Permission.microphone.isGranted &&
      await Permission.camera.isGranted;
    locationStatus =
      await Permission.location.isGranted;
    overlayStatus = 
      await Permission.systemAlertWindow.isGranted;
  }

  @override
  void initState() {
    super.initState();
    asyncMethod();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, toolbarHeight: 0),
      body: Center(
        child: Column(
          children:  [
            const Text("需要授予權限", style: TextStyle(fontSize: 50)),
            const SizedBox(height: 10),
            PermissionIndex(
              title: "藍芽",
              lore: "需要授予藍芽權限來連線至藍芽序列埠",
              status: bluetoothStatus,
              icon: Icons.bluetooth,
              onPressed: () async {
                if (bluetoothStatus) return;
                bluetoothStatus = true;

                switch(await Permission.bluetoothConnect.status){
                  case PermissionStatus.denied:
                    bluetoothStatus = await Permission.bluetoothConnect.request().isGranted && bluetoothStatus;
                    break;
                  case PermissionStatus.permanentlyDenied:
                    openAppSettings();
                    break;
                  case PermissionStatus.granted:
                    bluetoothStatus = true && bluetoothStatus;
                    break;
                  default:
                    bluetoothStatus = true && bluetoothStatus;
                }

                switch(await Permission.bluetoothAdvertise.status){
                  case PermissionStatus.denied:
                    bluetoothStatus = await Permission.bluetoothAdvertise.request().isGranted && bluetoothStatus;
                    break;
                  case PermissionStatus.permanentlyDenied:
                    openAppSettings();
                    break;
                  case PermissionStatus.granted:
                    bluetoothStatus = true && bluetoothStatus;
                    break;
                  default:
                    bluetoothStatus = true && bluetoothStatus;
                }

                switch(await Permission.bluetoothScan.status){
                  case PermissionStatus.denied:
                    bluetoothStatus = await Permission.bluetoothScan.request().isGranted && bluetoothStatus;
                    break;
                  case PermissionStatus.permanentlyDenied:
                    openAppSettings();
                    break;
                  case PermissionStatus.granted:
                    bluetoothStatus = true && bluetoothStatus;
                    break;
                  default:
                    bluetoothStatus = true && bluetoothStatus;
                }

                setState(() => settings.permsEnough.value = isAllGranted());
              }
            ),
            PermissionIndex(
              title: "相機",
              lore: "需要授予相機權限來錄製影片或拍照",
              status: cameraStatus,
              icon: Icons.camera,
              onPressed: () async {
                if (cameraStatus) return;
                cameraStatus = true;

                switch(await Permission.camera.status){
                  case PermissionStatus.denied:
                    cameraStatus = await Permission.camera.request().isGranted && cameraStatus;
                    break;
                  case PermissionStatus.permanentlyDenied:
                    openAppSettings();
                    break;
                  case PermissionStatus.granted:
                    cameraStatus = true && cameraStatus;
                    break;
                  default:
                    cameraStatus = true && cameraStatus;
                }

                switch(await Permission.microphone.status){
                  case PermissionStatus.denied:
                    cameraStatus = await Permission.microphone.request().isGranted && cameraStatus;
                    break;
                  case PermissionStatus.permanentlyDenied:
                    openAppSettings();
                    break;
                  case PermissionStatus.granted:
                    cameraStatus = true && cameraStatus;
                    break;
                  default:
                    cameraStatus = true && cameraStatus;
                }

                setState(() => settings.permsEnough.value = isAllGranted());
              }
            ),
            PermissionIndex(
              title: "位置",
              lore: "需要授予位置權限來竊取你的行蹤",
              status: locationStatus,
              icon: Icons.my_location,
              onPressed: () async {
                if (locationStatus) return;
                locationStatus = true;

                switch(await Permission.location.status){
                  case PermissionStatus.denied:
                    locationStatus = await Permission.location.request().isGranted && locationStatus;
                    break;
                  case PermissionStatus.permanentlyDenied:
                    openAppSettings();
                    break;
                  case PermissionStatus.granted:
                    locationStatus = true && locationStatus;
                    break;
                  default:
                    locationStatus = true && locationStatus;
                }

                setState(() => settings.permsEnough.value = isAllGranted());
              },
            ),
            PermissionIndex(
              title: "最上層顯示", 
              lore: "啟用Picture-In-Picture功能的必要權限", 
              status: overlayStatus,
              icon: Icons.picture_in_picture_alt_rounded,
              onPressed: () async {
                if (overlayStatus) return;
                overlayStatus = true;

                switch(await Permission.systemAlertWindow.status){
                  case PermissionStatus.denied:
                    overlayStatus = await Permission.systemAlertWindow.request().isGranted && overlayStatus;
                    break;
                  case PermissionStatus.permanentlyDenied:
                    openAppSettings();
                    break;
                  case PermissionStatus.granted:
                    overlayStatus = true && overlayStatus;
                    break;
                  default:
                    overlayStatus = true && overlayStatus;
                }
                setState(() => settings.permsEnough.value = isAllGranted());
              }
            )
          ]
        )
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "btn1",
        onPressed: () async {
          if (!(bluetoothStatus && cameraStatus)) return;
        },
        tooltip: '切換主題',
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}

class PermissionIndex extends StatefulWidget {
  final IconData icon;
  final String title, lore;
  final Function() onPressed;
  final bool status;

  const PermissionIndex({super.key, required this.title, required this.lore, required this.status, required this.icon, required this.onPressed,});

  @override
  State<PermissionIndex> createState() => _PermissionIndexState();
}

class _PermissionIndexState extends State<PermissionIndex> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 90, width: 90,
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.only(top: 3),
              decoration: BoxDecoration(
                color: widget.status ? Colors.green : Colors.orange,
                shape: BoxShape.circle
              ),
              child: Icon(widget.icon, size: 75),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(widget.title, style: TextStyle(fontSize: 50, height: 1, color: Theme.of(context).textTheme.displayMedium!.color)),
                  const Spacer(),
                  Text(widget.lore, style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.displayMedium!.color)),
                  const Spacer()
                ],
              ),
            ),
          ]
        ),
    
      )
    );
  }
}
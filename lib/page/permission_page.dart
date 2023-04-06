import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:doclosedoor/main.dart';

bool bluetoothStatus = false, cameraStatus = false, locationStatus = false;

class PermissionPage extends StatefulWidget {
  const PermissionPage({Key? key}) : super(key: key);

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  void asyncMethod() async{
    bluetoothStatus =
      await Permission.bluetoothConnect.status.isGranted &&
      await Permission.bluetoothAdvertise.status.isGranted &&
      await Permission.bluetoothScan.status.isGranted;
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
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 90, width: 90,
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: (bluetoothStatus) ? Colors.green : Colors.orange,
                        shape: BoxShape.circle
                      ),
                      child: const Icon(Icons.bluetooth, size: 80),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 90,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Spacer(),
                          Text("藍芽", style: TextStyle(fontSize: 50, height: 1)),
                          Spacer(),
                          Text("需要授予藍芽權限來連線至藍芽序列埠", style: TextStyle(fontSize: 14)),
                          Spacer()
                        ],
                      ),
                    ),
                  ]
                ),
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

                  setState(() => permsEnough.value = bluetoothStatus && cameraStatus && locationStatus);
                }
              )
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 90, width: 90,
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.only(top: 3),
                      decoration: BoxDecoration(
                        color: cameraStatus ? Colors.green : Colors.orange,
                        shape: BoxShape.circle
                      ),
                      child: const Icon(Icons.photo_camera_outlined, size: 75),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 90,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Spacer(),
                          Text("相機", style: TextStyle(fontSize: 50, height: 1)),
                          Spacer(),
                          Text("需要授予相機權限來錄製影片或拍照", style: TextStyle(fontSize: 14)),
                          Spacer()
                        ],
                      ),
                    ),
                  ]
                ),
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

                  setState(() => permsEnough.value = bluetoothStatus && cameraStatus && locationStatus);
                }
              )
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 90, width: 90,
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.only(top: 3),
                      decoration: BoxDecoration(
                          color: locationStatus ? Colors.green : Colors.orange,
                          shape: BoxShape.circle
                      ),
                      child: const Icon(Icons.location_on, size: 75),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 90,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Spacer(),
                          Text("位置", style: TextStyle(fontSize: 50, height: 1)),
                          Spacer(),
                          Text("需要授予位置權限來竊取你的行蹤", style: TextStyle(fontSize: 14)),
                          Spacer()
                        ],
                      ),
                    ),
                  ]
                ),
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

                  setState(() => permsEnough.value = bluetoothStatus && cameraStatus && locationStatus);
                }
              )
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

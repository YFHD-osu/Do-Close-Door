import 'package:floating/floating.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import './../main.dart';
import 'home_page.dart';

const MethodChannel wakeLock = MethodChannel('flutter.dev/PowerManager/Wakelock');
bool isInCloseDelay = false, cameraOrignalState = false;
int? lastTemperature;
ValueNotifier<bool> bluetoothPageListener = ValueNotifier<bool>(false);
List<BluetoothDevice> devices = [];
BluetoothConnection? connection;
BluetoothDevice? currentDevice;
AppLifecycleState? notification; 

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({Key? key}) : super(key: key);

  @override
  State<BluetoothPage> createState() => BluetoothPageState();
}

class BluetoothPageState extends State<BluetoothPage> with WidgetsBindingObserver{
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      notification = state;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FlutterBluetoothSerial.instance.getBondedDevices().then((value) => setState(() => devices = value));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, toolbarHeight: 0),
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: bluetoothPageListener,
            builder: (context, counter, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 100, width: 100,
                    margin: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: currentDevice == null ? Colors.orange : Colors.blue,
                      shape: BoxShape.circle
                    ),
                    child: const Icon(Icons.bluetooth, size: 80),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentDevice == null ? "未連接至裝置" : currentDevice!.name.toString(), style: const TextStyle(fontSize: 30)),
                      Text(currentDevice == null ? "位置: 未連線" : "位置: ${currentDevice!.address}"),
                      Text(connection == null ? "狀態: 未連接" : connection!.isConnected ? "狀態: 已連接" : "狀態: 未連接"),
                      Text("驗證: 已認證"),
                    ],
                  )
                ],
              );
            },
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(left: 10),
            child: const Text("可用裝置",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 40)
            ),
          ),
          Column(
            children: devices.map<InkWell>((BluetoothDevice device) {
              late IconData icon;
              switch(device.type.toUnderlyingValue()){
                case 1: // Classic
                  icon = Icons.arrow_forward;
                  break;
                case 3: // Dual
                  icon = Icons.compare_arrows;
                  break;
                case 2: // le
                  icon = Icons.battery_full;
                  break;
                default:
                  icon = Icons.question_mark;
              }
              return InkWell(
                child: Container(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  width: MediaQuery.of(context).size.width-20,
                  height: 40,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Icon(icon),
                      const SizedBox(width:10),
                      Text(device.name.toString(), style: const TextStyle(fontSize:20)),
                      const Spacer(),
                    ],
                  )
                ),
                onTap: () async {
                  try{
                    if (connection != null) {
                      connection!.finish();
                      bluetoothPageListener.value = !bluetoothPageListener.value;
                      currentDevice = connection = null;
                      return;
                    }
                    connection = await BluetoothConnection.toAddress(device.address);
                    setState(() => currentDevice = device);
                    connection!.input?.listen(handleCommands).onDone(() {
                      connection = currentDevice = null;
                      homePageListener.value = !homePageListener.value;
                      bluetoothPageListener.value = !bluetoothPageListener.value;
                      print('Disconnected by remote request');
                    });
                  }catch (exception) {
                    print('Cannot connect, exception occured: \n ${exception.toString()}');
                    return;
                  }
                },
              );
            }).toList(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "btn1",
        onPressed: () async {
          devices = await FlutterBluetoothSerial.instance.getBondedDevices();
        },
        tooltip: '切換主題',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

void connectionDialog (BuildContext context) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: '',
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim1),
        child: child,
      );
    },
    pageBuilder: (context, anim1, anim2) {
      return StatefulBuilder(
        builder: (context, setState){
          return WillPopScope(
            onWillPop: () async {
              return true;
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height - 60,
                  width: MediaQuery.of(context).size.width - 60,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(width: 10),
                      Text("連線中"),
                    ],
                  )
                )
              ]
            ),
          );
        }
      );
    }
  );
}

Future<void> handleCommands (Uint8List data) async {
  List<String> command = ascii.decode(data).split(":");
  //  if (await floating.pipStatus == PiPStatus.disabled && 
  //      lastAppState == AppLifecycleState.paused) return;
  print("Bluetooth Function Called!");
  print("Camera ininital? = ${cameraController.value.isInitialized}");
  print("Camera previewPause? = ${cameraController.value.isPreviewPaused}");
  if (command[0] == "cmd" && command.length == 3) {
    switch(command[1]){
      case "start_record":
        cameraOrignalState = cameraController.value.isPreviewPaused;
        if (!cameraController.value.isRecordingVideo) {
          if (cameraOrignalState) cameraController.resumePreview();
          cameraController.startVideoRecording().then((value) => homePageListener.value = !homePageListener.value);
        }
        break;
      case "stop_record":
        if (!cameraController.value.isRecordingVideo) return;
        if (isInCloseDelay) return;
        isInCloseDelay = true;

        await Future.delayed(const Duration(milliseconds: 500));

        try{
          XFile media = await cameraController.stopVideoRecording();
          DateTime now = DateTime.now();
          media.saveTo("${settings.appPath!.path}/${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}-${now.second}-$lastTemperature-${command[2]}.mp4");
          print("[Saving] ${settings.appPath!.path}/${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}-${now.second}-$lastTemperature-${command[2]}.mp4");
          if (cameraOrignalState) cameraController.pausePreview();
          isInCloseDelay = false;
        }catch (e){
          await switchResolution();
          print("SaveError!!!!!!");
        }finally{
          
        }

        homePageListener.value = !homePageListener.value;
        break;
    }
  }
}

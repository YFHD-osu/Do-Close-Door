import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import './../settings_value.dart';
import 'dart:convert';
import 'home_page.dart';

int? lastTemperature;
String lastCommand = "";
BluetoothDevice? currentDevice;
BluetoothConnection? connection;
AppLifecycleState? notification;
List<BluetoothDevice> devices = [];
bool isInCloseDelay = false, cameraOrignalState = false;
ValueNotifier<bool> bluetoothPageListener = ValueNotifier<bool>(false);
const MethodChannel wakeLock = MethodChannel('flutter.dev/PowerManager/Wakelock');

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
                      Icon(getDeviceIcon(device)),
                      const SizedBox(width:10),
                      Text(device.name.toString(), style: const TextStyle(fontSize:20)),
                      const Spacer(),
                    ],
                  )
                ),
                onTap: () async => connectionDialog(context, device),
              );
            }).toList(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "btn1",
        onPressed: () async {
          devices = await FlutterBluetoothSerial.instance.getBondedDevices();
          setState(() {});
        },
        tooltip: '切換主題',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class ConnectionDialog extends StatefulWidget {
  const ConnectionDialog({super.key, required this.device});
  final BluetoothDevice device;
  @override
  State<ConnectionDialog> createState() => ConnectionDialogState();
}

class ConnectionDialogState extends State<ConnectionDialog> {
  double? progressBarValue = 0;
  String connectStatus = "連線已就緒";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 360,
          width: MediaQuery.of(context).size.width - 60,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: const BorderRadius.all(Radius.circular(10))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: (progressBarValue==null) ? null : () => Navigator.pop(context), 
                    child: const Text("取消")
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: (progressBarValue==null) ? null : () => (connection==null) ? deviceConnect(widget.device) : deciveDisconnect(), 
                    child: Text(connection==null ? "連線" : "中斷連線")
                  )
                ]
              ),
              Center(
                child: Column(
                  children: [
                    Icon(getDeviceIcon(widget.device),size: 100),
                    Text(widget.device.name.toString(), style: const TextStyle(fontSize: 30))
                  ]
                )
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("連線狀態: ${widget.device.isConnected ? "已連線" : "未連線"}"),
                    Text("裝置位址: ${widget.device.address}"),
                    Text("藍芽模式: ${getDeviceType(widget.device)}"),
                    Text("配對狀態: ${getDeviceBond(widget.device)}")
                  ]
                )
              ),
              const Spacer(),
              Center(child: Text(connectStatus)),
              const Spacer(),
              LinearProgressIndicator(
                value: progressBarValue,
              ),
            ]
          )
        )
      ]
    );
  }

  void deciveDisconnect() {
    if (connection != null) { // Disconnect current device if available
      connection!.finish();
      bluetoothPageListener.value = !bluetoothPageListener.value;
      currentDevice = connection = null;
      connectStatus = "連線成功中斷!";
      setState(() {});
      return;
    }
  }

  void deviceConnect(BluetoothDevice device) async {
    connectStatus = "連線到裝置中...";
    setState(() => progressBarValue = null);
    deciveDisconnect();
    try{
      connection = await BluetoothConnection.toAddress(device.address);
      bluetoothPageListener.value = !bluetoothPageListener.value;
      setState(() => currentDevice = device);
      connection!.input?.listen(handleCommands).onDone(() {
        connection = currentDevice = null;
        homePageListener.value = !homePageListener.value;
        bluetoothPageListener.value = !bluetoothPageListener.value;
        print('Disconnected by remote request');
      });
      connectStatus = "連線成功!";
    }catch (exception) {
      if (exception.toString().contains("closed or timeout")) {
        connectStatus = "連線失敗 (與裝置溝通超時)";
      }else {
        connectStatus = "連線失敗 (使用接上Console可看完整錯誤)";
        //print('Cannot connect, exception occured: \n ${exception.toString()}');
      }
    }
    setState(() => progressBarValue = 0);
  }
}

void connectionDialog (BuildContext context, BluetoothDevice device) async =>
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
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.white),
              child: ConnectionDialog(device: device),
            ),
            onWillPop: () async {
              return false;
            },
          );
        }
      );
    }
  );

Future<void> handleCommands (Uint8List? data) async {
  final List<String> command = ((data == null) ? lastCommand : ascii.decode(data)).replaceAll("\n", "").split(":");
  print("[Bluetooth Function] Camera ininital? = ${cameraController.value.isInitialized} Camera previewPause? = ${cameraController.value.isPreviewPaused}");
  if (!(command[0] == "cmd" && (command.length == 3 || command.length == 4))) return;
  if (data == null && lastCommand.isEmpty) return;
  if (isInCloseDelay) {
    lastCommand = (data == null) ? lastCommand : ascii.decode(data);
    Future.delayed(const Duration(milliseconds: 500)).then((value) => handleCommands(null));
    return;
  } else {lastCommand = "";}
  switch(command[1]){
    case "start_record":
      cameraOrignalState = cameraController.value.isPreviewPaused;
      if (cameraController.value.isRecordingVideo) return;
      isInCloseDelay = true;
      if (cameraOrignalState) cameraController.resumePreview();
      cameraController.startVideoRecording().then((value) => homePageListener.value = !homePageListener.value);
      break;
    case "stop_record":
      if (!cameraController.value.isRecordingVideo) return;
      isInCloseDelay = true;
      final DateTime now = DateTime.now();
      final String filename = "${settings.appPath!.path}/media/${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}-${now.second}-$lastTemperature-${command[2]}.mp4";
      final XFile media = await cameraController.stopVideoRecording();
      if (command.last == "1") media.saveTo(filename);
      if (cameraOrignalState) cameraController.pausePreview();
      homePageListener.value = !homePageListener.value;
      break;
  }
  isInCloseDelay = false;
}

IconData getDeviceIcon(BluetoothDevice device) {
  switch(device.type.toUnderlyingValue()){
    case 1: // Classic
      return Icons.arrow_forward;
    case 3: // Dual
      return Icons.compare_arrows;
    case 2: // le
      return Icons.battery_full;
    default:
      return Icons.question_mark;
  }
}

String getDeviceType(BluetoothDevice device) {
  switch(device.type.toUnderlyingValue()){
    case 1: // Classic
      return "Bluetooth Classic";
    case 3: // Dual
      return "Dual-Mode Bluetooth";
    case 2: // le
      return "Bluetooth Low Energy";
    default:
      return "未知類型";
  }
}

String getDeviceBond(BluetoothDevice device){
  switch(device.bondState.toUnderlyingValue()){
    case 12: //bonded
      return "曾經配對";
    case 11: //bonding
      return "已經配對";
    case 10: //none
      return "尚未配對";
    default:  //unknown
      return "未知狀態";
  }
}
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

List<BluetoothDevice> devices = [];
BluetoothConnection? connection;
BluetoothDevice? currentDevice;

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({Key? key}) : super(key: key);

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  void asyncMethod() async {
    devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {});
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
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: 100,
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
                  Text(currentDevice == null ? "未連接至裝置" : currentDevice!.name.toString(), style: TextStyle(fontSize: 30)),
                  Text(currentDevice == null ? "位置: 未連線" : "位置: ${currentDevice!.address}"),
                  Text(connection == null ? "狀態: 未連接" : connection!.isConnected ? "狀態: 已連接" : "狀態: 未連接"),
                  Text("驗證: 已認證"),
                ],
              )
            ],
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
              Widget _status = SizedBox();
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
                      _status,
                    ],
                  )
                ),
                onTap: () async {
                  try{
                    if (connection != null) {
                      connection!.finish();
                      currentDevice = null;
                      connection = null;
                      setState(() {});
                      return;
                    }
                    setState(() => _status = const CircularProgressIndicator());
                    connection = await BluetoothConnection.toAddress(device.address);
                    currentDevice = device;
                    connection!.input?.listen((Uint8List data) {
                      print('Data incoming: ${ascii.decode(data)}');
                      connection!.output.add(data); // Sending data

                      if (ascii.decode(data).contains('!')) {
                        connection!.finish(); // Closing connection
                        print('Disconnecting by local host');
                      }
                    }).onDone(() {
                      print('Disconnected by remote request');
                    });
                    setState(() => _status = const Icon(Icons.check));
                  }catch (exception) {
                    print('Cannot connect, exception occured');
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

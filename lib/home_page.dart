import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'bluetooth_page.dart';
import 'main.dart';

final List<String> resolutions = ["240p", "480p", "720p", "1080p", "3840p", "Auto"];
late List<CameraDescription> _cameras;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraController cameraController;
  String? currentResolution;
  int currentCamera = 0;

  void switchCamera() {
    switch(currentResolution){
      case "240p":
        cameraController = CameraController(_cameras[currentCamera], ResolutionPreset.low);
        break;
      case "480p":
        cameraController = CameraController(_cameras[currentCamera], ResolutionPreset.medium);
        break;
      case "720p":
        cameraController = CameraController(_cameras[currentCamera], ResolutionPreset.high);
        break;
      case "1080p":
        cameraController = CameraController(_cameras[currentCamera], ResolutionPreset.veryHigh);
        break;
      case "3840p":
        cameraController = CameraController(_cameras[currentCamera], ResolutionPreset.ultraHigh);
        break;
      case "Auto":
        cameraController = CameraController(_cameras[currentCamera], ResolutionPreset.max);
        break;
      default:
        cameraController = CameraController(_cameras[currentCamera], ResolutionPreset.max);
    }

    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
          // Handle access errors here.
            break;
          default:
          // Handle other errors here.
            break;
        }
      }
    });

  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero,() async {
      _cameras = await availableCameras();
    });
    cameraController = CameraController(_cameras[0], ResolutionPreset.veryHigh);
    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
          // Handle access errors here.
            break;
          default:
          // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("攝影客戶端")),
        body: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 86),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)),
                        child: cameraController.value.isInitialized ? Transform.scale(
                            scale: cameraController.value.aspectRatio,
                            child: Center(child: CameraPreview(cameraController))
                        ) : const Center(child: CircularProgressIndicator()),
                      )
                  ),
                  Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).inputDecorationTheme.fillColor,
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 5, height: 0),
                          IconButton(
                              icon: const Icon(Icons.cameraswitch_outlined),
                              onPressed: () {
                                if(_cameras.length == currentCamera + 1){
                                  currentCamera = 0;
                                }else{
                                  currentCamera += 1;
                                }
                                switchCamera();
                                setState(() {});
                              }
                          ),
                          Icon(Icons.video_camera_back_outlined, color: Theme.of(context).inputDecorationTheme.labelStyle!.color, size: 35),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              isExpanded: true,
                              hint: Text(
                                resolutions[cameraController.resolutionPreset.index],
                                style: const TextStyle(fontSize: 20),
                              ),
                              items: _addDividersAfterItems(resolutions),
                              value: currentResolution,
                              onChanged: (value) {
                                currentResolution = value as String;
                                switchCamera();
                                setState(() {});
                              },
                              buttonStyleData: const ButtonStyleData(height: 40, width: 110),
                              dropdownStyleData: const DropdownStyleData(
                                offset:  Offset(0, 240),
                                scrollPadding: EdgeInsets.symmetric(vertical: 2),
                                decoration:  BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                ),
                                maxHeight: 200,
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                  padding: EdgeInsets.zero,
                                  height: 40
                              ),
                            ),
                          ),
                        ],
                      )
                  )
                ],
              ),
            )
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "btn1",
              onPressed: () {
                cameraController.pausePreview();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const BluetoothPage()),
                ).then((value) => cameraController.resumePreview());

              },
              tooltip: '藍芽設定',
              child: const Icon(Icons.bluetooth),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              heroTag: "btn2",
              onPressed: () => setState(() {
                print(cameraController.resolutionPreset.index);
              }),
              tooltip: 'Increment',
              child: const Icon(Icons.alarm),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              heroTag: "btn3",
              onPressed: () => setState(() {
                isLight.value = !(isLight.value);
              }),
              tooltip: '切換主題',
              child: Icon(isLight.value ? Icons.sunny : Icons.nightlight),
            ),
          ],
        )
    );
  }
}

List<DropdownMenuItem<String>> _addDividersAfterItems(List<String> items) {
  List<DropdownMenuItem<String>> menuItems = [];
  for (var item in items) {
    menuItems.addAll(
      [
        DropdownMenuItem<String>(
          value: item,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: Text(item, style: const TextStyle(fontSize: 20)),
          ),
        ),

        if (item != items.last)
          const DropdownMenuItem<String>(
            enabled: false,
            child: Divider(),
          ),
      ],
    );
  }
  return menuItems;
}
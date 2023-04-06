import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'bluetooth_page.dart';
import '../main.dart';

late CameraController cameraController;
late List<CameraDescription> cameras;
final List<String> resolutions = ["240p", "480p", "720p", "1080p", "3840p", "Auto"];
final List<ResolutionPreset> resolutionPreset = [
  ResolutionPreset.low, ResolutionPreset.medium, ResolutionPreset.high,
  ResolutionPreset.veryHigh, ResolutionPreset.ultraHigh, ResolutionPreset.max
];
ValueNotifier<bool> homePageListener = ValueNotifier<bool>(false);
String currentResolution = "Auto";
int currentCamera = 0;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
    switchResolution(mounted: mounted).then((bool value) => setState(() {}));
    homePageListener.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    cameraController.dispose();
    homePageListener.removeListener(() {});
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
                      child: Stack(
                        children: [
                          Center(child: CameraPreview(cameraController)),
                          Visibility(
                            visible: cameraController.value.isPreviewPaused,
                            child: Container(
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
                              child: const Center(child: Text("預覽已暫停")),
                            )
                          )
                        ],
                      )
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
                      Visibility(
                        visible: !cameraController.value.isRecordingVideo,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(cameraController.value.isPreviewPaused ? Icons.visibility : Icons.visibility_off),
                              onPressed: () async {
                                if (cameraController.value.isPreviewPaused) {
                                  await cameraController.resumePreview();
                                }else{
                                  await cameraController.pausePreview();
                                }
                                setState(() {});
                              }
                            ),
                            IconButton(
                              icon: const Icon(Icons.cameraswitch_outlined),
                              onPressed: () {
                                if(cameras.length == currentCamera + 1) {currentCamera = 0;}
                                else {currentCamera += 1;}
                                switchResolution(mounted: mounted).then((bool value) => setState(() {}));
                              }
                            ),
                            ElevatedButton(
                              child: Row(
                                children: [
                                  const Icon(Icons.video_camera_back_outlined, size: 30),
                                  const SizedBox(width: 5),
                                  Text(currentResolution, style: const TextStyle(fontSize: 20))
                                ],
                              ),
                              onPressed: () async => changeResolutionDialog(context)
                            )
                          ],
                        )
                      ),

                      Visibility(
                        visible: cameraController.value.isRecordingVideo,
                        child: Container(
                          padding: const EdgeInsets.only(right: 5, top: 4, bottom: 4),
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(30)
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.fiber_manual_record, size: 30),
                              SizedBox(width: 2),
                              Text("錄製中", style: TextStyle(fontSize: 20))
                            ],
                          ),
                        )
                      )
                    ],
                  )
                ),
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
                ).then((value) => cameraController.resumePreview())
                .then((value) => setState(() {}));
              },
              tooltip: '藍芽設定',
              child: Icon((connection == null) ? Icons.bluetooth : Icons.bluetooth_connected),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              heroTag: "btn2",
              onPressed: () async {
                const platform = MethodChannel('samples.flutter.dev/battery');
                final int result = await platform.invokeMethod('getBatteryLevel');
                String batteryLevel = 'Battery level at $result % .';
              },
              tooltip: '檔案設定',
              child: const Icon(Icons.folder),
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

void changeResolutionDialog (BuildContext context) async {
  await showGeneralDialog(
      context: context,
      barrierDismissible: true,
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
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      width: double.infinity,
                      height: 350,
                      decoration: BoxDecoration(
                          color: Theme.of(context).inputDecorationTheme.fillColor,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              TextButton(
                                  child: const Text("取消"),
                                  onPressed: () => Navigator.pop(context)
                              ),
                              Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(top: 5),
                                child: const Text("影片解析度設定", style: TextStyle(fontSize: 25, color: Colors.white)),
                              ),
                            ],
                          ),
                          Column(
                            children: resolutions.map((String resolution) {
                              return Container(
                                  height: 40,
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.all(5),
                                  child: ElevatedButton(
                                    child: Text(resolution),
                                    onPressed: () {
                                      currentResolution = resolution;
                                      Navigator.pop(context);
                                      switchResolution().then((bool value) => homePageListener.value = !homePageListener.value);
                                    },
                                  )
                              );
                            }).toList(),
                          )
                        ],
                      )
                  )
                ],
              );
            }
        );
      }
  );
}

Future<bool> switchResolution({bool mounted = true}) async {
  cameraController = CameraController(cameras[currentCamera], resolutionPreset[resolutions.indexOf(currentResolution!)]);
  await cameraController.initialize().then((_) {
    if (!mounted) {return;}
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
  return true;
}

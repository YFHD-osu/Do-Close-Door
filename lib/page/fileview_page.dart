import 'package:flutter/material.dart';
import 'dart:io';
import './../settings_value.dart';

List<FileSystemEntity> entities = [];

class FileViewPage extends StatefulWidget {
  const FileViewPage({super.key});

  @override
  State<FileViewPage> createState() => _FileViewPageState();
}

class _FileViewPageState extends State<FileViewPage> {
  
  
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 0)).then((value) async {
      entities = await Directory("${settings.appPath!.path}/media").list().toList();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, toolbarHeight: 0),
      body: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(Icons.folder, size: 80),
              Text("錄製資料", style: TextStyle(fontSize: 50))
            ],
          ),
          Expanded(
            child: ListView(
              
            )
          )
        ],
      ),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      
    );
  }
}
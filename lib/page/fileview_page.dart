import 'package:flutter/material.dart';

class FileViewPage extends StatefulWidget {
  const FileViewPage({super.key});

  @override
  State<FileViewPage> createState() => _FileViewPageState();
}

class _FileViewPageState extends State<FileViewPage> {
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
              children: [
                
              ],
            )
          )
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'theme.dart' ;

ValueNotifier<bool> isLight = ValueNotifier<bool>(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
    isLight.addListener(() => setState(() {})); // Detect theme change
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '監聽攝影機',
      theme: isLight.value ? AppThemeData.lightMode : AppThemeData.darkMode,
      home: const MyHomePage(),
    );
  }
}




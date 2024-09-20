
import 'package:file_manager/utils/navigate.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/views/folder.dart';
import 'utils/theme_config.dart';



var isFirst;
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
 Future<void> requestPermission() async {
  final status = await Permission.manageExternalStorage.request();

  if (status.isPermanentlyDenied) {
    // If the permission is permanently denied, open app settings
    openAppSettings();
  } else if (status.isDenied) {
    // If permission is denied, you can request it again or handle accordingly
    // For example, show a message to the user explaining why the permission is needed
    print("Permission denied. Please grant the permission to continue.");
  } else if (status.isGranted) {
    // Permission granted, proceed with your logic
    print("Permission granted.");
  }
}

// Change screen logic based on permission status
Future<void> changeScreen() async {

  final status = await Permission.manageExternalStorage.status;

  if (!status.isGranted) {
    await requestPermission();
  } else {
    // Permission is already granted, proceed with your logic
    print("Permission already granted.");
  }
}
  @override 
  void initState() {
    super.initState();
  //  isFirstLaunch();
    changeScreen();
  }
  // isFirstLaunch() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var first = preferences.getBool('first_time');
  //   isFirst = first;
  //   if (first == null) {
  //     preferences.setBool('first_time', false);
  //   }

  //   if (!isFirst) {
  //       // ignore: use_build_context_synchronously
  //       Navigate.pushPageReplacement(context, const Folder(path: '/storage/emulated/0/'));
  //     } 
  // }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeConfig.lightTheme,
        darkTheme: ThemeConfig.darkTheme,
        home: Folder(path: '/storage/emulated/0/'));
        // Container(color: Colors.white,));
  }
}

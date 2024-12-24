import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:zizzle/Controllers/video_controller.dart';
import 'package:zizzle/Screens/Splash_screen.dart';
import 'package:zizzle/resources/firestore_reels_updation.dart';
import 'package:zizzle/resources/updation_firestore.dart';
import 'package:zizzle/services/navigation_service.dart';
import 'package:zizzle/utils/utils.dart';

import 'ads/ads_manager.dart';
import 'firebase_options.dart';

void main() async {
  // var devices = ["BE0C8B85F080056D4D28817B2AE3DA5B"];

  WidgetsFlutterBinding.ensureInitialized();
  String unityAdsGameId = Platform.isIOS ? '5544948' : '5544949';
  await UnityAds.init(
    gameId: unityAdsGameId,
    onComplete: () => print('Initialization Complete'),
    onFailed: (error, message) =>
        print('Initialization Failed: $error $message'),
  );
  Admanager().loadrewardedad();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await registerservices();
  await SharedPreferences.getInstance();
  // Access the VideoController and call preloadVideos
  // final videoController = await Get.putAsync(() async => VideoController());
  // await videoController.preloadVideos();

  await FirestoreUpdater().updateGlobalOptionStatusForUser();
  await FirestoreReelUpdater().updateGlobalOptionStatusForUser();
  // Future.delayed(Duration(seconds: 5));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GetIt _getIt = GetIt.instance;
  late Navigationservice _navigationservice;
  MyApp({super.key}) {
    _navigationservice = _getIt.get<Navigationservice>();
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: _navigationservice.navigatorkey,
      debugShowCheckedModeBanner: false,
      title: 'Zizzle',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black12),
      routes: _navigationservice.routes,
      home: SplashScreen(),
      initialBinding: BindingsBuilder(() {
        Get.put(VideoController());
      }),
    );
  }
}

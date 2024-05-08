import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:newapp/Controllers/video_controller.dart';
import 'package:newapp/Screens/Splash_screen.dart';
import 'package:newapp/Screens/login_screen.dart';
import 'package:newapp/resources/firestore_reels_updation.dart';
import 'package:newapp/resources/updation_firestore.dart';
import 'package:newapp/utils/colors.dart';
import 'package:newapp/widgets/reel_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'ads/ads_manager.dart';
import 'firebase_options.dart';
import 'dart:io';
void main() async {
  // var devices = ["BE0C8B85F080056D4D28817B2AE3DA5B"];
  WidgetsFlutterBinding.ensureInitialized();
  String unityAdsGameId = Platform.isIOS
      ? '5544948'
      : '5544949';
  await UnityAds.init(
    gameId: unityAdsGameId,
    onComplete: () => print('Initialization Complete'),
    onFailed: (error, message) => print('Initialization Failed: $error $message'),
  );
  Admanager().loadrewardedad();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedPreferences.getInstance();
  // Access the VideoController and call preloadVideos
  // final videoController = await Get.putAsync(() async => VideoController());
  // await videoController.preloadVideos();
  await FirestoreUpdater().updateGlobalOptionStatusForUser();
  await FirestoreReelUpdater().updateGlobalOptionStatusForUser();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zizzle',
      theme: ThemeData.dark()
          .copyWith(scaffoldBackgroundColor: Colors.black12),
       home:SplashScreen(),
    initialBinding:BindingsBuilder((){
      Get.put(VideoController());
    }) ,
    );
  }

}

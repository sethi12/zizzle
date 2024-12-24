import 'package:flutter_svg/flutter_svg.dart';
import '/Screens/login_screen.dart';
import 'package:flutter/material.dart';
import '/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../responsive/mobile_screen_layout.dart';
import '../responsive/responsive_screen_layout.dart';
import '../responsive/web_screen_layout.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
  static String? username = _SplashScreenState.username;
}

class _SplashScreenState extends State<SplashScreen> {
  static String? username;

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 5), () {
      checkLoginState();
    });

    return Scaffold(
        backgroundColor: mobileBackgroundColor,
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 170),
                child: Image.asset(
                  'assets/applogo.jpeg',
                  height: 110,
                  width: 100,
                ),
              ),
              Text(
                "create,post,earn",
                style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 200),
                child: Text("from"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "InbredTechno",
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 19),
                  ),
                  Image.asset(
                    'assets/companylogo.jpeg',
                    height: 40,
                    width: 20,
                  )
                ],
              )
            ],
          ),
        ));
  }

  void checkLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');

    if (username != null && username!.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            MobileScreenLayout: MobileScreenLayout(),
            WebScreenLayout: WebScreenLayout(),
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }
}

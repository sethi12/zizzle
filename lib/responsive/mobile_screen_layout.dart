import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/Screens/Search_screen.dart';
import '/Screens/Splash_screen.dart';
import '/Screens/add_screen.dart';
import '/Screens/feed_screen.dart';
import '/Screens/login_screen.dart';
import '/Screens/profile_screen.dart';
import '/Screens/reel_screen.dart';
import '/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/Userdata.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController;

  void navigationtapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }

  void onpagechanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    // var userData = getUser();
    return Scaffold(
      body: PageView(
        children: [
          const FeedScreen(),
          const SearchScreen(),
          const AddScreen(),
          VideoScreen(),
          FirebaseAuth.instance.currentUser?.uid != null
              ? ProfileScreen(
                  uid: FirebaseAuth.instance.currentUser!.uid,
                )
              : ProfileScreen(
                  username: LoginScreen.globalusername,
                ),
        ],
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onpagechanged,
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: mobileBackgroundColor,
        iconSize: 23.0,
        onTap: navigationtapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 23.0,
              color: _page == 0 ? primaryColor : secondaryColor,
            ),
            label: '',
            backgroundColor: mobileBackgroundColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              color: _page == 1 ? primaryColor : secondaryColor,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle,
              color: _page == 2 ? primaryColor : secondaryColor,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.shower,
              color: _page == 3 ? primaryColor : secondaryColor,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _page == 4 ? primaryColor : secondaryColor,
            ),
            label: '',
          ),
        ],
      ),

      //   Center(
      //     child: FutureBuilder(
      //     future: userData,
      //     builder: (context, snapshot) {
      //       if (snapshot.connectionState == ConnectionState.waiting) {
      //         return CircularProgressIndicator(); // or some loading indicator
      //       }
      //
      //       if (snapshot.hasError) {
      //         return Text('Error: ${snapshot.error}');
      //       }
      //
      //       UserData? user = snapshot.data;
      //       String username = user?.username ?? '';
      //       String email = user?.email ?? '';
      //       // List<String> followers = user?.followers ?? [];
      //       return Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           Text('Username: $username'),
      //           Text('Email: $email'),
      //           // Text('followers: $followers'),
      //         ],
      //       );
      //     },
      //   ),
      // ),
    );
  }
}

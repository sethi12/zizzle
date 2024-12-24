import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:zizzle/Screens/notificationscreen.dart';
import 'package:zizzle/utils/utils.dart';
import '/Screens/Home_screen.dart';
import '/Screens/Test_Reel_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ads/ads_manager.dart';
import '../services/navigation_service.dart';
import '../utils/colors.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // late BannerAd bannerAd;
  // bool isAdloadede=false;
  // var adunitid ="ca-app-pub-4186886227081667/7751093350";
  // initbannerad(){
  //   bannerAd = BannerAd(size: AdSize.banner,
  //       adUnitId:adunitid,
  //       listener: BannerAdListener(
  //         onAdLoaded: (ad){
  //           setState(() {
  //             isAdloadede = true;
  //           });
  //         },
  //         onAdFailedToLoad: (ad,error){
  //           ad.dispose();
  //           print(error);
  //       }
  //       ),
  //       request:const AdRequest()
  //   );
  //   bannerAd.load();
  // }
  final GetIt _getIt = GetIt.instance;
  late Navigationservice _navigationservice;
  var username;
  var followingList;
  bool hasCollabRequests = false;
  bool _isloaded = false;
  void getusername() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    print(username);
    var userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();

    if (userSnapshot.exists) {
      followingList = userSnapshot['following'] != null
          ? List.from(userSnapshot['following'])
          : [];
      print('Following List: $followingList');
      setState(() {
        _isloaded = true;
      });
    } else {
      print('User document not found for username: $username');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getusername();
    // initbannerad();
    Admanager().loadrewardedad();
    _navigationservice = _getIt.get<Navigationservice>();
    checkCollabRequests();
  }

  Future<void> checkCollabRequests() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("CollabRequests")
        .where('collabusername', isEqualTo: username)
        .get();

    // Update state based on whether there are collab requests
    setState(() {
      hasCollabRequests = querySnapshot.docs.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isloaded
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              automaticallyImplyLeading:
                  false, // Remove the default back button
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Zizzle",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => TestReelScreen()));
                        },
                        child: Text(
                          "Reels",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    // Handle notification action
                    checkCollabRequests();
                    // Refresh collab requests on click
                    if (hasCollabRequests == false) {
                      showSnackBar("No Collab Request found", context);
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Notificationscreen(username: username)));
                    }
                  },
                  icon: Icon(
                    Icons.notification_add_sharp,
                    color: hasCollabRequests ? Colors.red : Colors.grey,
                  ),
                ),
                IconButton(
                  icon: Icon(
                      Icons.chat_bubble_outline_rounded), // Use the chat icon
                  onPressed: () {
                    // Add your chat functionality here
                    _navigationservice.pushnamed("/home");
                  },
                ),
              ],
            ),
            body: GestureDetector(
              onHorizontalDragEnd: (details) {
                // Detect swipe direction
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! > 0) {
                  _navigationservice.pushnamed("/home");
                }
              },
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('Posts').snapshots(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Filter posts based on the 'username' field in the 'followingList'
                  List<DocumentSnapshot<Map<String, dynamic>>> globalPosts =
                      snapshot.data!.docs
                          .where(
                              (post) => post['isGlobalOptionEnabled'] == true)
                          .toList();

                  // List for posts where the username is in the 'followingList'
                  List<DocumentSnapshot<Map<String, dynamic>>> followingPosts =
                      snapshot.data!.docs
                          .where((post) =>
                              post['username'] != null &&
                              followingList.contains(post['username']) &&
                              post['Audience'] == 'Public')
                          .toList();

                  // Combine both lists
                  List<DocumentSnapshot<Map<String, dynamic>>> combinedPosts = [
                    ...globalPosts,
                    ...followingPosts
                  ];

                  return ListView.builder(
                      itemCount: combinedPosts.length,
                      itemBuilder: (context, index) {
                        return PostCard(
                          snap: combinedPosts[index].data(),
                        );
                      });
                },
              ),
            ))
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}

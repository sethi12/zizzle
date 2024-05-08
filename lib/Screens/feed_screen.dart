import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newapp/Screens/Test_Reel_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ads/ads_manager.dart';
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
  var username;
  var followingList;
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
  }

  @override
  Widget build(BuildContext context) {
    return _isloaded
        ? Scaffold(
        appBar: AppBar(
            backgroundColor: mobileBackgroundColor,
            automaticallyImplyLeading: false, // Remove the default back button
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
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>TestReelScreen()));
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
        )),
        body: StreamBuilder(
          stream:
          FirebaseFirestore.instance.collection('Posts').snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Filter posts based on the 'username' field in the 'followingList'
            List<DocumentSnapshot<Map<String, dynamic>>> globalPosts =
            snapshot.data!.docs
                .where((post) => post['isGlobalOptionEnabled'] == true)
                .toList();

            // List for posts where the username is in the 'followingList'
            List<DocumentSnapshot<Map<String, dynamic>>> followingPosts =
            snapshot.data!.docs
                .where((post) =>
            post['username'] != null &&
                followingList.contains(post['username'])&&post['Audience']=='Public')
                .toList();

            // Combine both lists
            List<DocumentSnapshot<Map<String, dynamic>>> combinedPosts =
            [...globalPosts, ...followingPosts];

            return ListView.builder(
                itemCount: combinedPosts.length,
                itemBuilder: (context, index) {

                  return PostCard(
                    snap: combinedPosts[index].data(),
                  );

                });
          },
        ))
        : const Center(
      child: CircularProgressIndicator(),
    );
  }
}
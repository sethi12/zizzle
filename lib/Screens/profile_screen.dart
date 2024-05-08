import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newapp/Controllers/profile_video_controller.dart';
import 'package:newapp/Screens/CollabReelScreen.dart';
import 'package:newapp/Screens/CollabRequst.dart';
import 'package:newapp/Screens/Edit_profile_Screen.dart';
import 'package:newapp/Screens/MonitizationScreen.dart';
import 'package:newapp/Screens/MonthlyTransaction.dart';
import 'package:newapp/Screens/Profile_reel_screen.dart';
import 'package:newapp/Screens/Splash_screen.dart';
import 'package:newapp/Screens/WalletScreen.dart';
import 'package:newapp/Screens/add_post_screen.dart';
import 'package:newapp/Screens/add_reel_screen.dart';
import 'package:newapp/Screens/pending_Screen.dart';
import 'package:newapp/Screens/profileimagecheckScreen.dart';
import 'package:newapp/Screens/reel_screen.dart';
import 'package:newapp/resources/firestoremethods.dart';
import 'package:newapp/utils/colors.dart';
import 'package:newapp/utils/utils.dart';
import 'package:newapp/widgets/CircleTickIcon.dart';
import 'package:newapp/widgets/CircleTickIconSearch.dart';
import 'package:newapp/widgets/CollabedReel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/WalletScreenUi.dart';
import '../widgets/follow_button.dart';
import 'Update_password_screen.dart';
import 'login_screen.dart';

enum ProfileViewOption {
  Public,
  Reels,
  Private,
}

class ProfileScreen extends StatefulWidget {
  final String? uid;
  final String? username;
  ProfileScreen({super.key, this.uid, this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userdata = {};
  int postLen = 0;
  int reelLen = 0;
  int totallen = 0;
  int followers = 0;
  int following = 0;
  bool isfollowing = false;
  bool myfollowing = false;
  bool _isLoading = false;
  String? myusername;
  var storeduid;
  var useruid;
  var usersnap;
 bool existance = false;
  var getstatus;
 late DateTime getexpirydate;
  ProfileViewOption selectedOption = ProfileViewOption.Public;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
    useruid = widget.uid;
    print(useruid);
  }

  getdata() async {
    setState(() {
      _isLoading = true;
    });

    print(widget.uid);
    print(widget.username);
    final prefs = await SharedPreferences.getInstance();
    myusername = prefs.getString('username');
    print(myusername);
    try {
      var existingUser = await FirebaseFirestore.instance
          .collection("users")
          .doc(myusername)
          .get();
      print(existingUser);
      if (existingUser.exists) {
        storeduid = existingUser.data()?['uid'];
        print(storeduid);
      }
      if (widget.uid != null) {
        usersnap = await FirebaseFirestore.instance
            .collection("users")
            .where('uid',
                isEqualTo: widget
                    .uid) // Use widget.uid instead of FirebaseAuth.instance.currentUser!.uid
            .get();
      } else {
        usersnap = await FirebaseFirestore.instance
            .collection("users")
            .where('uid',
                isEqualTo:
                    storeduid) // Use widget.uid instead of FirebaseAuth.instance.currentUser!.uid
            .get();
        // Use widget.uid instead of FirebaseAuth.instance.currentUser!.uid
      }
      if (usersnap.docs.isNotEmpty) {
        userdata = usersnap.docs.first.data() as Map<String, dynamic>;
        isfollowing = (userdata['followers'] as List).contains(myusername);
        myfollowing =
            (userdata['following'] as List).contains(userdata['username']);
        // get the post length
        var postSnap = await FirebaseFirestore.instance
            .collection("Posts")
            .where("uid", isEqualTo: userdata['uid'])
            .get();
        var Reelsnap = await FirebaseFirestore.instance
            .collection("reels")
            .where("uid", isEqualTo: userdata['uid'])
            .get();

        postLen = postSnap.docs.length;
        reelLen = Reelsnap.docs.length;
        totallen = postLen + reelLen;
        followers = (userdata['followers'] as List).length;
        following = (userdata['following'] as List).length;
        var paiduser = await FirebaseFirestore.instance.collection("Requests").doc(myusername).get();
        if(paiduser.exists) {
          existance = true;
          print(existance);
          getstatus = paiduser.data()?['status'];
          Timestamp timestamp = paiduser.data()?['Expiry Date'];
          getexpirydate = timestamp.toDate(); // Convert Timestamp to DateTime
          print(getstatus);
          print(getexpirydate);

          if (getexpirydate != null && getexpirydate.isAfter(DateTime.now())) {
            var daysRemaining = getexpirydate.difference(DateTime.now()).inDays;
            print('Days remaining until expiry: $daysRemaining days');
          } else if (getexpirydate != null && getexpirydate.isBefore(DateTime.now())) {
            print('The expiry date has already passed.');
            // Add logic for handling the case when the expiry date has passed (e.g., show a message)
          } else {
            print('Invalid or missing expiry date.');
          }

        }

        setState(() {});
      }
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  String? getCondition() {
    if (widget.uid != null) {
      return widget.uid;
    } else {
      return storeduid ?? userdata['uid'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Row(
                children: [
                  Text(userdata['username']),
                  userdata['Monetization']=="Monitized"?
                  CircleTickIcon():SizedBox()
                ],
              ),
              centerTitle: false,
              actions: [
                (storeduid == widget.uid) ||
                        (widget.uid == null && storeduid == userdata['uid'])
                    ? Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        height: 200,
                                        width: double.infinity,
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 20),
                                              child: Center(
                                                child: Text(
                                                  "Create",
                                                  style:
                                                      TextStyle(fontSize: 22),
                                                ),
                                              ),
                                            ),
                                            const Divider(
                                              height: 1,
                                              thickness: 3,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: GestureDetector(
                                                  onTap: () => Navigator.of(
                                                          context)
                                                      .push(MaterialPageRoute(
                                                          builder: (context) =>
                                                              AddpostScreen())),
                                                  child: Text(
                                                    "Post",
                                                    style:
                                                        TextStyle(fontSize: 22),
                                                  )),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: GestureDetector(
                                                  onTap: () => Navigator.of(
                                                          context)
                                                      .push(MaterialPageRoute(
                                                          builder: (context) =>
                                                              AddreelScreen())),
                                                  child: Text(
                                                    "Reel",
                                                    style:
                                                        TextStyle(fontSize: 22),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              },
                              icon: Icon(
                                Icons.add_box,
                                size: 30,
                              )),
                          IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SingleChildScrollView(
                                        child: Container(
                                          width: double.infinity,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20),
                                                child: Text(
                                                  "Settings",
                                                  style: TextStyle(fontSize: 24),
                                                ),
                                              ),const Divider(thickness: 3.0,),
                                              // Padding(
                                              //   padding:
                                              //       const EdgeInsets.symmetric(
                                              //           vertical: 5),
                                              //   child: InkWell(
                                              //     onTap: () {},
                                              //     child: Row(
                                              //       mainAxisAlignment:
                                              //           MainAxisAlignment
                                              //               .spaceEvenly,
                                              //       children: [
                                              //         Text(
                                              //           "Theme",
                                              //           style: TextStyle(
                                              //               fontSize: 22),
                                              //         ),
                                              //       ],
                                              //     ),
                                              //   ),
                                              // ),
                                              // const Divider(),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: InkWell(
                                                  onTap: () {
                                                    if(followers>=500){
                                                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MonetizationPolicy()));
                                                    }else{
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => Dialog(
                                                          child: ListView(
                                                            padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 17),
                                                            shrinkWrap: true,
                                                            children: [
                                                              const  SizedBox(height: 20,),
                                                              const Text("Required Followers 500",style: TextStyle(fontSize:19,fontWeight: FontWeight.bold),),
                                                              const  SizedBox(height: 20,),
                                                              ].toList(),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Text(
                                                        "Monetization",
                                                        style: TextStyle(
                                                            fontSize: 22),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const Divider(),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: InkWell(
                                                  onTap: ()async{
                                                        await resetPassword(userdata['email']);
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Text(
                                                        "Change Password",
                                                        style: TextStyle(
                                                            fontSize: 22),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const Divider(),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: InkWell(
                                                  onTap: () {
                                                    if (userdata['Monetization'] == "Monitized"){
                                                      if(existance == true && getstatus=='pending'){
                                                        // pending page
                                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => PendingScreen()));
                                                      }else if(existance ==true && getstatus=='Approved'&&getexpirydate.isAfter(DateTime.now())){
                                                        // received monthly income page
                                                        print(getexpirydate);
                                                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MonthlyTransaction()));
                                                      }

                                                      else if(existance == true && getstatus=='Approved'&&getexpirydate.isBefore(DateTime.now())){
                                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => WalletScreen()));
                                                      }
                                                      else if(existance==false){
                                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => WalletScreen()));
                                                      }
                                                    } else {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => Dialog(
                                                          backgroundColor: Colors.black.withOpacity(1.0),
                                                          child: ListView(
                                                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 17),
                                                            shrinkWrap: true,
                                                            children: [
                                                              Text("Account Not Monetized"),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }


                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Text(
                                                        "Wallet",
                                                        style: TextStyle(
                                                            fontSize: 22),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ), const Divider(thickness: 2.0,),
                                              Padding(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 5),
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>CollabRequests(username: myusername,)));
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                    children: [
                                                      Text(
                                                        "Post Collab Requests",
                                                        style: TextStyle(
                                                            fontSize: 22),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ), const Divider(thickness: 2.0,),
                                              Padding(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 5),
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CollabReelScreen(username: myusername)));
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                    children: [
                                                      Text(
                                                        "Reel Collab Requests",
                                                        style: TextStyle(
                                                            fontSize: 22),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),const Divider(thickness: 2.0,),
                                              Padding(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 5),
                                                child: InkWell(
                                                  onTap: ()async{
                                                    await _logout(context);
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                    children: [
                                                      Text(
                                                        "Log Out",
                                                        style: TextStyle(
                                                            fontSize: 24),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                              ],
                                          ),
                                        ),
                                      );
                                    });
                              },
                              icon: Icon(
                                Icons.more_horiz_rounded,
                                size: 30,
                              )),
                        ],
                      )
                    : Row()
              ],
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(userdata['photourl']),
                            radius: 45,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildStatColumn(totallen, "posts"),
                                    buildStatColumn(followers, "followers"),
                                    buildStatColumn(following, "following"),
                                  ],
                                ),
                                // Text("hello how are you",style: TextStyle(color: Colors.white),),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    (storeduid == widget.uid) ||
                                            (widget.uid == null &&
                                                storeduid == userdata['uid'])
                                        ? FollowButton(
                                            text: "Edit Profile",
                                            bordercolor: Colors.grey,
                                            backgroundcolor:
                                                mobileBackgroundColor,
                                            textcolor: primaryColor,
                                            function: () => Navigator.of(
                                                    context)
                                                .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditProfileScreen())),
                                          )
                                        : isfollowing
                                            ? FollowButton(
                                                text: "Unfollow",
                                                bordercolor: Colors.grey,
                                                backgroundcolor: Colors.white,
                                                textcolor: Colors.black,
                                                function: () async {
                                                  await Firestoremethods()
                                                      .followuser(myusername!,
                                                          userdata['username']);
                                                  setState(() {
                                                    isfollowing = false;
                                                    followers--;
                                                  });
                                                },
                                              )
                                            : FollowButton(
                                                text: "Follow",
                                                bordercolor: Colors.blue,
                                                backgroundcolor: Colors.blue,
                                                textcolor: Colors.white,
                                                function: () async {
                                                  await Firestoremethods()
                                                      .followuser(myusername!,
                                                          userdata['username']);
                                                  setState(() {
                                                    isfollowing = true;
                                                    followers++;
                                                  });
                                                },
                                              )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 15),
                        child: Row(
                          children: [
                            Text(
                              userdata['name'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            userdata['Monetization']=="Monitized"?
                            CircleTickIconSearch():SizedBox()
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          userdata['Category'] ?? '',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                      Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(top: 1),
                          child: Text(
                            userdata['Bio'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ],
                  ),
                ),
                const Divider(),
                (storeduid == widget.uid) ||
                        (widget.uid == null && storeduid == userdata['uid'])
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedOption = ProfileViewOption.Public;
                                });
                              },
                              child: Text(
                                "Public",
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              )),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedOption = ProfileViewOption.Reels;
                              });
                            },
                            child: Text(
                              "Reels",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedOption = ProfileViewOption.Private;
                              });
                            },
                            child: Text(
                              "Private",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    : myfollowing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedOption = ProfileViewOption.Public;
                                    });
                                  },
                                  child: Text(
                                    "Public",
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
                                  )),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedOption = ProfileViewOption.Reels;
                                  });
                                },
                                child: Text(
                                  "Reels",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedOption = ProfileViewOption.Private;
                                  });
                                },
                                child: Text(
                                  "Private",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedOption = ProfileViewOption.Public;
                                    });
                                  },
                                  child: Text(
                                    "Public",
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
                                  )),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedOption = ProfileViewOption.Reels;
                                  });
                                },
                                child: Text(
                                  "Reels",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                const Divider(),
                StreamBuilder(
                    stream: getPostsByOptionStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return GridView.builder(
                        physics: ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: (snapshot.data! as dynamic).docs.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 1.5,
                            crossAxisSpacing: 5,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            DocumentSnapshot snap =
                                (snapshot.data! as dynamic).docs[index];
                            return Container(
                              child: selectedOption == ProfileViewOption.Reels
                                  ? Stack(children: [
                                      InkWell(
                                        onTap: () {
                                          if (useruid != null) {
                                            // Assuming 'id' is the key in your data
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileVideoScreen(
                                                          uid: useruid,
                                                          videoid: snap['id'],
                                                        )));
                                          } else {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileVideoScreen(
                                                          uid: storeduid,
                                                          videoid: snap['id'],
                                                        )));
                                          }
                                        },
                                        child: Image(
                                          image:
                                              NetworkImage((snap['thumbnail'])),
                                          fit: BoxFit.cover,
                                          width: 250,
                                        ),
                                      ),
                                      Positioned(
                                        // Adjust the position as needed
                                        // top: 120,right: 110
                                        child: Container(
                                          width: double.infinity,
                                          height: 25,
                                          color: Colors.black.withOpacity(
                                              0.7), // Adjust the opacity as needed
                                          child: Text(
                                            (snap['views'] >= 1000)
                                                ? "${(snap['views'] / 1000).toStringAsFixed(snap['views'] % 1000 == 0 ? 0 : 1)}k views"
                                                : "${snap['views']} views",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ])
                                  : InkWell(
                                      onTap: () {},
                                      child: InkWell(
                                        onTap: () {
                                          if (useruid != null) {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfiileImageCheckScreen(
                                                            uid: useruid)));
                                          } else {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfiileImageCheckScreen(
                                                            uid: storeduid)));
                                          }
                                        },
                                        child: Image(
                                          image:
                                              NetworkImage((snap['posturl'])),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                            );
                          });
                    })
              ],
            ),
          );
  }

  Stream<QuerySnapshot> getPostsByOptionStream() {
    if (selectedOption == ProfileViewOption.Reels) {
      return FirebaseFirestore.instance
          .collection("reels")
          .where('uid', isEqualTo: getCondition())
          .snapshots();
    } else if (selectedOption == ProfileViewOption.Private) {
      return FirebaseFirestore.instance
          .collection("Posts")
          .where('uid', isEqualTo: getCondition())
          .where('Audience', isEqualTo: 'Private')
          .snapshots();
    }

    // Retrieve all posts (Public and Private)
    return FirebaseFirestore.instance
        .collection("Posts")
        .where('uid', isEqualTo: getCondition())
        .where('Audience', isEqualTo: 'Public')
        .snapshots();
  }
Future<void>resetPassword(String email)async{
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>UpadtePassword(email: userdata['email'],)));
    }catch(e){
      print(e.toString());
    }
}
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear shared preferences data
     await FirebaseAuth.instance.signOut();
    // Navigate to login screen and remove previous screens from the stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 1),
          child: Text(
            label,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

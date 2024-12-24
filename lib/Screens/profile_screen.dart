import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zizzle/Screens/close_friends_screen.dart';
import 'package:zizzle/Screens/collabuserpostscreen.dart';
import 'package:zizzle/Screens/profileimagecheckprivatescreen.dart';
import '/Screens/followersScreen.dart';
import '/Screens/followingScreen.dart';
import '/model/user.dart' as u;
import 'package:rxdart/rxdart.dart' as rx;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import '/Controllers/profile_video_controller.dart';
import '/Screens/CollabReelScreen.dart';
import '/Screens/CollabRequst.dart';
import '/Screens/Edit_profile_Screen.dart';
import '/Screens/MonitizationScreen.dart';
import '/Screens/MonthlyTransaction.dart';
import '/Screens/Profile_reel_screen.dart';
import '/Screens/Splash_screen.dart';
import '/Screens/WalletScreen.dart';
import '/Screens/add_post_screen.dart';
import '/Screens/add_reel_screen.dart';
import '/Screens/chat_screen.dart';
import '/Screens/pending_Screen.dart';
import '/Screens/profileimagecheckScreen.dart';
import '/Screens/reel_screen.dart';
import '/resources/firestoremethods.dart';
import '/utils/colors.dart';
import '/utils/utils.dart';
import '/widgets/CircleTickIcon.dart';
import '/widgets/CircleTickIconSearch.dart';
import '/widgets/CollabedReel.dart';
import '/widgets/followerscard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/alert_service.dart';
import '../services/auth_message_service.dart';
import '../services/database_service.dart';
import '../services/navigation_service.dart';
import '../widgets/WalletScreenUi.dart';
import '../widgets/follow_button.dart';
import 'Update_password_screen.dart';
import 'login_screen.dart';

enum ProfileViewOption { Public, Reels, Private, collabs }

class ProfileScreen extends StatefulWidget {
  final String? uid;
  final String? username;
  u.User? user;
  ProfileScreen({super.key, this.uid, this.username, this.user});

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
  final GetIt _getIt = GetIt.instance;
  late Navigationservice _navigationservice;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  late AuthService _authService;
  Set<String> closeFriends = {};
  bool isclose = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
    useruid = widget.uid;
    print(useruid);
    _navigationservice = _getIt.get<Navigationservice>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    _authService = _getIt.get<AuthService>();
  }

  Future<void> loadCloseFriends() async {
    try {
      // Fetch the user document based on their username or uid (assuming 'userdata['username']' holds the correct identifier)
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(userdata[
              'username']) // or use userdata['uid'] if username is not available
          .get();

      if (snapshot.exists) {
        var data = snapshot.data();
        // Check if the current user ID is in the closeFriends list
        if (data != null &&
            data['closeFriends'] != null &&
            data['closeFriends'].contains(storeduid)) {
          print("yesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyes");
          setState(() {
            isclose = true;
          });
        } else {
          setState(() {
            isclose = false;
          });
        }
      }
    } catch (e) {
      print('Error loading close friends: $e');
    }
  }

  getdata() async {
    setState(() {
      _isLoading = true;
    });

    print(widget.uid);
    print(widget.username);
    final prefs = await SharedPreferences.getInstance();
    myusername = prefs.getString('username');

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
        var paiduser = await FirebaseFirestore.instance
            .collection("Requests")
            .doc(myusername)
            .get();
        if (paiduser.exists) {
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
          } else if (getexpirydate != null &&
              getexpirydate.isBefore(DateTime.now())) {
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
    loadCloseFriends();
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
                  userdata['Monetization'] == "Monitized"
                      ? CircleTickIcon()
                      : SizedBox()
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
                                                  style:
                                                      TextStyle(fontSize: 24),
                                                ),
                                              ),
                                              const Divider(
                                                thickness: 3.0,
                                              ),
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
                                                    if (followers >= 500) {
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  MonetizationPolicy()));
                                                    } else {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            Dialog(
                                                          child: ListView(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        16,
                                                                    horizontal:
                                                                        17),
                                                            shrinkWrap: true,
                                                            children: [
                                                              const SizedBox(
                                                                height: 20,
                                                              ),
                                                              const Text(
                                                                "Required Followers 500",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        19,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                              ),
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
                                                  onTap: () async {
                                                    await resetPassword(
                                                        userdata['email']);
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
                                                    if (userdata[
                                                            'Monetization'] ==
                                                        "Monitized") {
                                                      if (existance == true &&
                                                          getstatus ==
                                                              'pending') {
                                                        // pending page
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        PendingScreen()));
                                                      } else if (existance ==
                                                              true &&
                                                          getstatus ==
                                                              'Approved' &&
                                                          getexpirydate.isAfter(
                                                              DateTime.now())) {
                                                        // received monthly income page
                                                        print(getexpirydate);
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        MonthlyTransaction()));
                                                      } else if (existance ==
                                                              true &&
                                                          getstatus ==
                                                              'Approved' &&
                                                          getexpirydate
                                                              .isBefore(DateTime
                                                                  .now())) {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        WalletScreen()));
                                                      } else if (existance ==
                                                          false) {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        WalletScreen()));
                                                      }
                                                    } else {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            Dialog(
                                                          backgroundColor:
                                                              Colors.black
                                                                  .withOpacity(
                                                                      1.0),
                                                          child: ListView(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        16,
                                                                    horizontal:
                                                                        17),
                                                            shrinkWrap: true,
                                                            children: [
                                                              Text(
                                                                  "Account Not Monetized"),
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
                                              ),
                                              const Divider(
                                                thickness: 2.0,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                CollabRequests(
                                                                  username:
                                                                      myusername,
                                                                )));
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
                                              ),
                                              const Divider(
                                                thickness: 2.0,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                CollabReelScreen(
                                                                    username:
                                                                        myusername)));
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
                                              ),
                                              const Divider(
                                                thickness: 2.0,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: InkWell(
                                                  onTap: () async {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                CloseFriendsScreen(
                                                                  uid:
                                                                      storeduid,
                                                                )));
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Text(
                                                        "Close Friends",
                                                        style: TextStyle(
                                                            fontSize: 24),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const Divider(
                                                thickness: 2.0,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: InkWell(
                                                  onTap: () async {
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
                                    GestureDetector(
                                        onTap: () {
                                          print(
                                              (userdata['followers'] as List));
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FollowersScreen(
                                                        uid: widget.uid,
                                                      )));
                                        },
                                        child: buildStatColumn(
                                            followers, "followers")),
                                    GestureDetector(
                                        onTap: () {
                                          print(
                                              (userdata['following'] as List));
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FollowingScreen(
                                                        uid: widget.uid,
                                                      )));
                                        },
                                        child: buildStatColumn(
                                            following, "following")),
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
                                              ),
                                  ],
                                ),
                                (storeduid == widget.uid) ||
                                        (widget.uid == null &&
                                            storeduid == userdata['uid'])
                                    ? SizedBox()
                                    : FollowButton(
                                        text: "Message",
                                        bordercolor: Colors.grey,
                                        backgroundcolor: Colors.white24,
                                        textcolor: Colors.white,
                                        function: () async {
                                          final chatexists =
                                              await _databaseService
                                                  .checkchatexists(
                                            _authService.getCurrentUser()!.uid,
                                            widget.user!.uid,
                                          );
                                          print("Chat exists: $chatexists");
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => ChatPage(
                                                  chatuser: widget.user),
                                            ),
                                          );
                                          if (!chatexists) {
                                            await _databaseService.createchats(
                                                _authService
                                                    .getCurrentUser()!
                                                    .uid,
                                                widget.user!.uid);
                                            print("Chat created between users");
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => ChatPage(
                                                    chatuser: widget.user),
                                              ),
                                            );
                                          }
                                        },
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
                            userdata['Monetization'] == "Monitized"
                                ? CircleTickIconSearch()
                                : SizedBox()
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
                        (widget.uid == null && storeduid == userdata['uid']) ||
                        (isclose == true)
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
                                "Posts",
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
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedOption = ProfileViewOption.collabs;
                              });
                            },
                            child: Text(
                              "Collabs",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
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
                                "Posts",
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
                              setState(() {});
                            },
                            child: Text(
                              "Collabs",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          )
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
                              child: selectedOption ==
                                          ProfileViewOption.Reels ||
                                      selectedOption ==
                                          ProfileViewOption.collabs
                                  ? Stack(children: [
                                      InkWell(
                                        onTap: () {
                                          if (useruid != null) {
                                            // Assuming 'id' is the key in your data
                                            if (snap['collabusername'] !=
                                                userdata['username']) {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProfileVideoScreen(
                                                            uid: useruid,
                                                            videoid: snap['id'],
                                                          )));
                                            } else if (snap['collabusername'] ==
                                                userdata['username']) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Collabuserpostscreen(
                                                              collabusername:
                                                                  userdata[
                                                                      'username'],
                                                              videoid:
                                                                  snap['id'])));
                                            }
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
                                      snap['Audience'] == "Private"
                                          ? Positioned(
                                              child: Container(
                                              width: double.infinity,
                                              height: 40,
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              child: Text(
                                                "Private",
                                                textAlign: TextAlign.right,
                                              ),
                                            ))
                                          : SizedBox()
                                    ])
                                  : InkWell(
                                      onTap: () {},
                                      child: InkWell(
                                        onTap: () {
                                          if (useruid != null) {
                                            if (snap['Audience'] == "Public" &&
                                                snap['collabusername'] !=
                                                    userdata['username']) {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProfiileImageCheckScreen(
                                                              uid: useruid)));
                                            } else if (snap['Audience'] ==
                                                "Private") {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProfiileImageCheckPrivateScreen(
                                                              uid: useruid)));
                                            }
                                            // } else if (snap['collabusername'] ==
                                            //     userdata['username']) {
                                            //   Navigator.push(
                                            //       context,
                                            //       MaterialPageRoute(
                                            //           builder: (context) =>
                                            //               Collabuserpostscreen(
                                            //                   collabusername:
                                            //                       userdata[
                                            //                           'username'])));
                                            // }
                                          } else {
                                            if (snap['Audience'] == "Public") {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProfiileImageCheckScreen(
                                                              uid: storeduid)));
                                            } else if (snap['Audience'] ==
                                                "Private") {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProfiileImageCheckPrivateScreen(
                                                              uid: storeduid)));
                                            }
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
      if ((storeduid == widget.uid) ||
          (widget.uid == null && storeduid == userdata['uid']) ||
          (isclose == true)) {
        return FirebaseFirestore.instance
            .collection("reels")
            .where('uid', isEqualTo: getCondition())
            .snapshots();
      } else {
        return FirebaseFirestore.instance
            .collection("reels")
            .where('uid', isEqualTo: getCondition())
            .where('Audience', isEqualTo: 'Public')
            .snapshots();
      }
    } else if (selectedOption == ProfileViewOption.Private) {
      return FirebaseFirestore.instance
          .collection("Posts")
          .where('uid', isEqualTo: getCondition())
          .where('Audience', isEqualTo: 'Private')
          .snapshots();
    } else if (selectedOption == ProfileViewOption.collabs) {
      return FirebaseFirestore.instance
          .collection("reels")
          .where("collabusername", isEqualTo: userdata['username'])
          .snapshots();
    }
    // Retrieve all posts (Public and Private)
    return FirebaseFirestore.instance
        .collection("Posts")
        .where('uid', isEqualTo: getCondition())
        .where('Audience', isEqualTo: 'Public')
        .snapshots();
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UpadtePassword(
                    email: userdata['email'],
                  )));
    } catch (e) {
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
    _alertService.showToast(text: "logged out ", icon: Icons.check);
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

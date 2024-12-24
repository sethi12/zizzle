import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_location_search/flutter_location_search.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zizzle/songs/SpotifyService.dart';
import 'package:zizzle/songs/spotifyapp.dart';
import '/Screens/Collaborators_Screen.dart';
import '/Screens/Splash_screen.dart';
import '/Screens/add_post_screen.dart';
import '/Screens/feed_screen.dart';
import '/responsive/mobile_screen_layout.dart';
import '/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../resources/firestoremethods.dart';
import '../utils/colors.dart';

class AddpostScreenDetails extends StatefulWidget {
  String? collabuser;
  String? trackid;
  String? previewUrl;
  String? songname;
  Uint8List? selectedimage;
  AddpostScreenDetails(
      {super.key,
      this.collabuser,
      this.previewUrl,
      this.trackid,
      this.songname,
      this.selectedimage});

  @override
  State<AddpostScreenDetails> createState() => _AddpostScreenDetailsState();
  static String location = _AddpostScreenDetailsState._locationText;
  static var uid = _AddpostScreenDetailsState.uid;
}

class _AddpostScreenDetailsState extends State<AddpostScreenDetails> {
  static String _locationText = '';
  bool _useCurrentLocation = false;
  final TextEditingController _captioncontroller = TextEditingController();
  String public = "Public";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Uint8List? selectedimage = AddpostScreen.selectedimage;
  static var uid;
  var photourl;
  var collabuser = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.previewUrl != null) {
      SpotifyService().playPreview(widget.previewUrl!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          elevation: 0.9,
          title: Center(
            child: const Text(
              "New Post",
              style:
                  TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
            ),
          ),
          centerTitle: false,
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GestureDetector(
                  child: Text(
                    "Post",
                    style: TextStyle(fontSize: 17, color: Colors.blue),
                  ),
                  onTap: () {
                    getdata();
                    SpotifyService().stopPreview();
                  },
                  // onTap: getdata,
                ),
              ),
            )
          ],
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(children: [
          Container(
            height: 350, // Adjust the height as needed
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(40, 20, 40, 10),
            color: mobileBackgroundColor,
            child: widget.selectedimage != null
                ? Image.memory(
                    widget.selectedimage!, // Convert String to File
                    fit: BoxFit.cover,
                  )
                : const Center(
                    child: Text(
                      "No Image Selected",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
          ),
          Container(
              child: Column(children: [
            Container(
                alignment: Alignment.topLeft,
                height: 60,
                width: double.infinity,
                color: mobileBackgroundColor,
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: _captioncontroller,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 1.0),
                      hintText: "write a Caption"),
                  maxLines: null,
                  // hinttext: 'Caption',
                )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CollabScreen(),
                    ),
                  );

                  // Use the result (collabusername) here
                  if (result != null) {
                    setState(() {
                      collabuser = result;
                    });
                  } else {
                    setState(() {
                      collabuser = "";
                    });
                  }
                },
                child: Container(
                    alignment: Alignment.topLeft,
                    width: double.infinity,
                    color: mobileBackgroundColor,
                    child: Row(
                      children: [
                        Icon(Icons.people),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Invite Collaborators",
                          style: TextStyle(fontSize: 18),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.12),
                          child: Text(
                            collabuser,
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 333,
                          child: Column(
                            children: [
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                                  child: Text(
                                    "Audience",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ),
                              Divider(
                                color: Colors.grey,
                                height: 0.7,
                                thickness: 0.3,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  "Select your Audience ",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontStyle: FontStyle.italic),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 30),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      public = "Public";
                                    });
                                    print(public);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: Icon(Icons.people),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Text(
                                            "Public",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    public = "Private";
                                  });
                                  print(public);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Icon(Icons.person_rounded),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Text(
                                          "Private",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                },
                child: Container(
                    alignment: Alignment.topLeft,
                    width: double.infinity,
                    color: mobileBackgroundColor,
                    child: Row(
                      children: [
                        Icon(Icons.perm_identity_outlined),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Audience",
                          style: TextStyle(fontSize: 18),
                        ),
                        // SizedBox(
                        //   width: 190,
                        // ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.2),
                          child: Text(
                            public,
                            style: TextStyle(fontSize: 19),
                          ),
                        )
                      ],
                    )),
              ),
            ),
            Divider(
              color: Colors.white,
              thickness: 1,
              height: 0.7,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: GestureDetector(
                onTap: () {
                  location();
                },
                child: Container(
                    alignment: Alignment.topLeft,
                    width: double.infinity,
                    color: mobileBackgroundColor,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              "Add Location",
                              style: TextStyle(fontSize: 18),
                            )
                          ],
                        ),
                        Text(_locationText)
                      ],
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SpotifyApp(
                            selectedimage: widget.selectedimage,
                            caller: 'AddPostScreen',
                          )));
                },
                child: Container(
                    alignment: Alignment.topLeft,
                    width: double.infinity,
                    color: mobileBackgroundColor,
                    child: Row(
                      children: [
                        Icon(Icons.music_note_sharp),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Import Music",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    )),
              ),
            ),
            Text("${widget.songname}"),
          ]))
        ]))));
  }

  Future<void> location() async {
    LocationData? locationData = await LocationSearch.show(
        context: context,
        mode: Mode.overlay,
        searchBarHintColor: Colors.white,
        searchBarTextColor: Colors.white);

    if (locationData != null) {
      setState(() {
        _useCurrentLocation = locationData.address == null;
        _locationText = _useCurrentLocation
            ? 'Current Location: ${locationData.latitude}, ${locationData.longitude}'
            : locationData.address!;
      });

      if (_useCurrentLocation) {
        await getCurrentLocation();
      }
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _locationText =
            'Current Location: ${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _captioncontroller.dispose();
  }

  void getdata() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
      barrierDismissible: false,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      String? usernamee = prefs.getString('username');
      var existingUser =
          await _firestore.collection("users").doc(usernamee).get();
      print(existingUser);

      if (existingUser.exists) {
        uid = existingUser.data()?['uid'];
        photourl = existingUser.data()?['photourl'];
        if (usernamee != null) {
          String res = await Firestoremethods().uploadPost(
              _captioncontroller.text!,
              widget.selectedimage!,
              uid!,
              _locationText!,
              public!,
              usernamee!,
              photourl!,
              collabuser,
              widget.trackid,
              widget.previewUrl,
              widget.songname);
          Navigator.pop(context);
          if (res == "Success") {
            showSnackBar("posted", context);

            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => FeedScreen()));
          } else {
            showSnackBar("error: $res", context);
          }
        } else {
          showSnackBar("Username is null", context);
        }
      } else {
        showSnackBar("User data not found", context);
      }
    } catch (err) {
      print(err.toString());
    }
  }
}

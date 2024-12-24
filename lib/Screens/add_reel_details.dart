import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_location_search/flutter_location_search.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:zizzle/songs/SpotifyService.dart';
import 'package:zizzle/songs/spotifyapp.dart';
import '/Controllers/upload_video_controller.dart';
import '/utils/utils.dart';
import 'package:video_player/video_player.dart';

import '../utils/colors.dart';
import 'Collaborators_Screen.dart';

class AddReelDetails extends StatefulWidget {
  final File videofile;
  final String videopath;

  const AddReelDetails(
      {Key? key, required this.videofile, required this.videopath})
      : super(key: key);

  @override
  State<AddReelDetails> createState() => _AddReelDetailsState();
}

class _AddReelDetailsState extends State<AddReelDetails> {
  late VideoPlayerController _videoPlayerController;
  static String _locationText = '';
  bool _useCurrentLocation = false;
  final TextEditingController _captioncontroller = TextEditingController();
  String public = "Public";
  var collabuser = "";
  UploadVideoController uploadVideoController =
      Get.put(UploadVideoController());
  String _trackId = '';
  String _previewUrl = '';
  String _name = '';
  String _track = '';

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(widget.videofile)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController.play();
        _videoPlayerController.setLooping(true);
        _videoPlayerController.setVolume(1);
      });

    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.hasError) {
        print("Error: ${_videoPlayerController.value.errorDescription}");
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          elevation: 0.9,
          title: Center(
            child: const Text(
              "New Reel",
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
                  onTap: () => postreel(),
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
              child: VideoPlayer(_videoPlayerController)),
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
                      print(collabuser);
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
                        //   width: 100,
                        // )

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
                onTap: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SpotifyApp(caller: "Reels"),
                    ),
                  );

                  // Check if result is not null and contains the expected data
                  if (result != null && result is Map<String, dynamic>) {
                    setState(() {
                      _trackId = result['trackId']?.toString() ?? '';
                      _previewUrl = result['previewUrl']?.toString() ?? '';
                      _name = result['name']?.toString() ?? '';
                      _track = result['track']?.toString() ?? '';
                    });
                    _videoPlayerController.setVolume(0);
                    SpotifyService().playPreview(_previewUrl);
                  }
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
            Text(_name),
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

  void postreel() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
      barrierDismissible: false,
    );

    String res = await uploadVideoController.uploadvideo(
        _captioncontroller.text,
        public,
        _locationText,
        widget.videopath,
        collabuser,
        _name,
        _previewUrl,
        _track,
        _trackId);

    Navigator.pop(context); // Close the progress indicator dialog

    if (res == "Success") {
      showSnackBar("Posted", context);
    }
  }

  @override
  void didUpdateWidget(covariant AddReelDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videopath != oldWidget.videopath) {
      _videoPlayerController = VideoPlayerController.file(widget.videofile)
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController.play();
        });
    }
  }
}

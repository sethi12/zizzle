import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zizzle/Controllers/videoplayerwithsnog.dart';
import '/Controllers/profile_video_controller.dart';
import '/Controllers/video_controller.dart';
import '/Screens/Comment_reel_screen.dart';
import '/Screens/ReelLikesScreen.dart';
import '/Screens/profile_screen.dart';
import '/resources/firestoremethods.dart';
import '/widgets/Video_player.dart';
import '/widgets/circle_animation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/reel.dart';
import '../utils/utils.dart';
import 'GlobalReelBenefitScreen.dart';
import 'LikesScreen.dart';

class ProfileVideoScreen extends StatefulWidget {
  final uid;
  final videoid;
  ProfileVideoScreen({Key? key, required this.uid, required this.videoid})
      : super(key: key);

  @override
  State<ProfileVideoScreen> createState() => _ProfileVideoScreenState();
}

class _ProfileVideoScreenState extends State<ProfileVideoScreen> {
  late var data;
  late final ProfileVideoController videoController;
  var storeduid;
  var username;
  buildprofile(String profilephoto) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          Positioned(
            left: 5,
            child: Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image(
                  image: NetworkImage(profilephoto),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initialstate();
    // videoController.preloadVideos();
  }

  void initialstate() async {
    videoController = Get.put(ProfileVideoController(
      selecteduid: widget.uid,
      selectedvideoid: widget.videoid,
    ));
    if (videoController.selecteduid != widget.uid ||
        videoController.selectedvideoid != widget.videoid) {
      videoController.updateData(
        newid: widget.uid,
        newvideoid: widget.videoid,
      );
      print("true");
    }
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    var existinguser = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();
    storeduid = existinguser.data()?['uid'];
    print(storeduid);
    print(widget.uid);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    videoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: StreamBuilder<List<Video>>(
      stream: videoController.videoListStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('StreamBuilder: Waiting for data...');
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          print('StreamBuilder Error: ${snapshot.error}');
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('StreamBuilder: No data available.');
          return Center(
            child: Text('No data available.'),
          );
        }
        data =
            snapshot.data![0]; // Assuming you want the first item in the list

        return PageView.builder(
          itemCount: snapshot.data!.length,
          controller: PageController(initialPage: 0, viewportFraction: 1),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            data = snapshot.data![index];
            print("data uid is ${data.uid}");
            return Stack(
              children: [
                data.previewUrl == ""
                    ? VideoPlayerItem(
                        videourl: data.videourl,
                        id: data.id,
                        thumbnail: data.thumbnail,

                        // Pass the current index
                      )
                    : VideoPlayerItem(
                        videourl: data.videourl,
                        id: data.id,
                        thumbnail: data.thumbnail,
                        spotifyPreviewUrl: data.previewUrl,
                        // Pass the current index
                      ),
                Column(
                  children: [
                    const SizedBox(
                      height: 100,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  data.collabreqacc == false
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileScreen(
                                                            username:
                                                                data.username,
                                                            uid: data.uid)));
                                          },
                                          child: Text(
                                            data.username,
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : Row(
                                          children: [
                                            GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProfileScreen(
                                                                  username: data
                                                                      .username,
                                                                  uid: data
                                                                      .uid)));
                                                },
                                                child: Text(
                                                  data.username,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4, right: 4),
                                              child: Text(
                                                "and",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProfileScreen(
                                                                  username: data
                                                                      .collabusername)));
                                                },
                                                child: Text(
                                                  data.collabusername,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )),
                                          ],
                                        ),
                                  Text(
                                    data.caption,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    data.Location,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 100,
                            margin: EdgeInsets.only(top: size.height / 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildprofile(data.profilephoto),
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () => Firestoremethods()
                                          .LikeVideo(data.id, username),
                                      child: Icon(
                                        Icons.favorite,
                                        size: 40,
                                        color: data.likes.contains(username)
                                            ? Colors.red
                                            : Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Container(
                                                width: double.infinity,
                                                height: 800,
                                                child: ReelLikesScreen(
                                                  uid: data.uid,
                                                  postid: data.id,
                                                ),
                                              );
                                            });
                                      },
                                      child: Text(
                                        data.likes.length.toString(),
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CommentReelScreen(
                                                    id: data.id,
                                                  ))),
                                      child: Icon(
                                        Icons.comment,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      data.commentcount.toString(),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    data.uid == storeduid
                                        ? IconButton(
                                            onPressed: () {
                                              if (data.uid == storeduid) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => Dialog(
                                                    backgroundColor: Colors
                                                        .black
                                                        .withOpacity(1.0),
                                                    child: ListView(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 16,
                                                          horizontal: 17),
                                                      shrinkWrap: true,
                                                      children: [
                                                        InkWell(
                                                          child: Text(
                                                              "Delete Post"),
                                                          onTap: () async {
                                                            Firestoremethods()
                                                                .deletereel(
                                                                    data.id);
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        Divider(),
                                                        InkWell(
                                                          child: Text(
                                                              "Make it Global"),
                                                          onTap: () async {
                                                            if (data.Audience ==
                                                                'Public') {
                                                              if (data.isGlobalOptionEnabled ==
                                                                  false) {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(MaterialPageRoute(
                                                                        builder: (context) => GlobalReelBenfitScreen(
                                                                              docid: data.id,
                                                                            )));
                                                              } else {
                                                                showSnackBar(
                                                                    "Post Already Global",
                                                                    context);
                                                              }
                                                            } else {
                                                              showSnackBar(
                                                                  "Private post cant be Global",
                                                                  context);
                                                            }
                                                          },
                                                        )
                                                      ].toList(),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            icon: Icon(Icons.more_horiz),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                                CircleAnimation(
                                  child: buildmusicalbum('profile photo'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    ));
  }

  buildmusicalbum(String profilephoto) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(11),
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.grey, Colors.white],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image(
                image: NetworkImage(profilephoto),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

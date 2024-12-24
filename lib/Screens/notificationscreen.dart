import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zizzle/widgets/notification.dart';

class Notificationscreen extends StatefulWidget {
  final String username;
  const Notificationscreen({super.key, required this.username});

  @override
  State<Notificationscreen> createState() => _NotificationscreenState();
}

class _NotificationscreenState extends State<Notificationscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("CollabRequests")
            .where("collabusername", isEqualTo: widget.username)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data!.docs;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              // Extract fields from the Firestore document
              final docData = data[index].data();
              final profilePhoto =
                  docData['profimage'] ?? ''; // Default to empty if null
              final username =
                  docData['username'] ?? ''; // Adjust field name as necessary
              final collabusername = docData['collabusername'] ?? '';
              final thumbnail =
                  docData['thumbnail'] ?? ''; // Default to empty if null
              final postId =
                  docData['postid']; // Check for the existence of postid
              final postUrl =
                  docData['posturl'] ?? ''; // Extract posturl for posts

              // Check if postId exists, indicating it's a post
              if (postId != null && postId.isNotEmpty) {
                // Treat as a post, pass postUrl instead of thumbnail
                return NotificationWidget(
                  pofilephoto: profilePhoto,
                  collabusername: collabusername,
                  username: username,
                  thumbnail: postUrl,
                  message: "You have a new Post collab Request from",
                  type: "post", // Pass postUrl for posts
                );
              } else {
                // Treat as a reel, pass thumbnail
                return NotificationWidget(
                  pofilephoto: profilePhoto,
                  collabusername: collabusername,
                  username: username,
                  thumbnail: thumbnail,
                  message: "You have a new Reel collab Request from",
                  type: "reel", // Pass thumbnail for reels
                );
              }
            },
          );
        },
      ),
    );
  }
}

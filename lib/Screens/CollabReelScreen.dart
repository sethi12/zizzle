import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/widgets/CollabedReel.dart';
import '/widgets/Collabedpost.dart';

import '../utils/colors.dart';

class CollabReelScreen extends StatefulWidget {
  var username;
  CollabReelScreen({super.key, required this.username});

  @override
  State<CollabReelScreen> createState() => _CollabReelScreenState();
}

class _CollabReelScreenState extends State<CollabReelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text("Collab Requests reel"),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('CollabRequests')
            .where('reelid', isNull: false)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DocumentSnapshot<Map<String, dynamic>>> collabedRequestPosts =
              snapshot.data!.docs
                  .where((collabRequest) =>
                      collabRequest['collabusername'] == widget.username)
                  .toList();

          return ListView.builder(
            itemCount: collabedRequestPosts.length,
            itemBuilder: (context, index) {
              return CollabedReel(snap: collabedRequestPosts[index].data());
            },
          );
        },
      ),
    );
  }
}

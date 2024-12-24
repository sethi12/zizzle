import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/Collabedpost.dart';

class CollabRequests extends StatefulWidget {
  var username;

  CollabRequests({Key? key, required this.username}) : super(key: key);

  @override
  State<CollabRequests> createState() => _CollabRequestsState();
}

class _CollabRequestsState extends State<CollabRequests> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text("Collab Requests"),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('CollabRequests')
            .where('postid', isNull: false)
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
              return Collabedpost(snap: collabedRequestPosts[index].data());
            },
          );
        },
      ),
    );
  }
}

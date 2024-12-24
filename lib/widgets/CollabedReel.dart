import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/Screens/Reel_Screen_Search.dart';

class CollabedReel extends StatelessWidget {
  final snap;
  const CollabedReel({super.key, required this.snap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(snap['profimage']),
                radius: 22,
              ),
              SizedBox(
                width: 20,
              ),
              Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    snap['username'],
                    style: TextStyle(fontSize: 19),
                  )),
            ],
          ),
          SizedBox(
            height: 13,
          ),
          InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SearchVideoScreen(
                        uid: snap['uid'], videoid: snap['reelid'])));
              },
              child: Image.network(snap['thumbnail'])),
          Align(
              alignment: Alignment.topLeft,
              child: Text(
                "${snap['username']} wants to Collaborate with you ${snap['collabusername']}",
                style: TextStyle(fontSize: 17, color: Colors.white60),
              )),
          Row(
            children: [
              TextButton(
                  onPressed: () {
                    print(snap['reelid']);
                    FirebaseFirestore.instance
                        .collection("reels")
                        .doc(snap['reelid'])
                        .update({"collabreqacc": true});
                    FirebaseFirestore.instance
                        .collection("CollabRequests")
                        .doc(snap['reelid'])
                        .delete();
                  },
                  child: Text("Accept")),
              TextButton(
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection("CollabRequests")
                        .doc(snap['reelid'])
                        .delete();
                  },
                  child: Text("Decline")),
            ],
          )
        ],
      ),
    );
  }
}

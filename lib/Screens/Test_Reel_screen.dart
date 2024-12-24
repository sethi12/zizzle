import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/widgets/reel_card.dart';

class TestReelScreen extends StatefulWidget {
  const TestReelScreen({Key? key}) : super(key: key);

  @override
  State<TestReelScreen> createState() => _TestReelScreenState();
}

class _TestReelScreenState extends State<TestReelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Zizzle"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("reels").snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Filter reels where 'isGlobalOptionEnabled' is true
          List<DocumentSnapshot<Map<String, dynamic>>> globalReels = snapshot
              .data!.docs
              .where((reel) => reel['isGlobalOptionEnabled'] == true)
              .toList();

          return ListView.separated(
            itemCount: globalReels.length,
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(height: 37); // Adjust the height as needed
            },
            itemBuilder: (context, index) {
              return ReelCard(
                snap: globalReels[index].data(),
              );
            },
          );
        },
      ),
    );
  }
}

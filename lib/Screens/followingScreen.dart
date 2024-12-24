import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/followerscard.dart';
import 'package:flutter/material.dart';

class FollowingScreen extends StatefulWidget {
  final uid;
  const FollowingScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  var username;

  @override
  void initState() {
    super.initState();
    getUsername(widget.uid);
  }

  Future<void> getUsername(String uid) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: uid)
          .get();

      if (querySnapshot.size > 0) {
        var data = querySnapshot.docs.first.data();
        setState(() {
          username = data['username'];
        });
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _getFollowingDetails(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Following of ${username}')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(username)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('User not found.'),
            );
          }

          var userData = snapshot.data!.data();
          var following = userData?['following'] ?? [];
          if (following.isEmpty) {
            return const Center(
              child: Text('No following found.'),
            );
          }

          return ListView.builder(
            itemCount: following.length,
            itemBuilder: (context, index) {
              var followingId = following[index];
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _getFollowingDetails(followingId),
                builder: (context, detailsSnapshot) {
                  if (detailsSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading...'),
                    );
                  }
                  if (detailsSnapshot.hasError) {
                    return ListTile(
                      title: Text('Error loading following details'),
                    );
                  }
                  if (!detailsSnapshot.hasData || !detailsSnapshot.data!.exists) {
                    return ListTile(
                      title: Text('Following details not found'),
                    );
                  }
                  var details = detailsSnapshot.data!.data()!;
                  return FollowersCard(
                    photourl: details['photourl'] ?? '',
                    username: details['username'] ?? '',
                    uid: details['uid'] ?? '',
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

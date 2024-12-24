import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/followerscard.dart';
import 'package:flutter/material.dart';

class CloseFriendsScreen extends StatefulWidget {
  final uid;
  const CloseFriendsScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<CloseFriendsScreen> createState() => _CloseFriendsScreenState();
}

class _CloseFriendsScreenState extends State<CloseFriendsScreen> {
  var username;
  Set<String> _selectedUsers = {}; // Selected users for close friends
  Set<String> _closeFriends = {}; // Existing close friends list
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getUsername(widget.uid);
  }

  Future<void> getUsername(String uid) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('users')
          .where('uid', isEqualTo: uid)
          .get();

      if (querySnapshot.size > 0) {
        var data = querySnapshot.docs.first.data();
        setState(() {
          username = data['username'];
          loadCloseFriends(username);
        });
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  Future<void> loadCloseFriends(String username) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(username).get();

      if (userDoc.exists) {
        var data = userDoc.data();
        setState(() {
          _closeFriends = Set<String>.from(data?['closeFriends'] ?? []);
          _selectedUsers = Set.from(_closeFriends); // Initialize selection
        });
      }
    } catch (e) {
      print('Error loading close friends: $e');
    }
  }

  void _toggleCloseFriend(String userId, bool isSelected) async {
    try {
      if (isSelected) {
        // Add user to closeFriends
        await _firestore.collection('users').doc(username).update({
          'closeFriends': FieldValue.arrayUnion([userId]),
        });
        setState(() {
          _closeFriends.add(userId);
        });
      } else {
        // Remove user from closeFriends
        await _firestore.collection('users').doc(username).update({
          'closeFriends': FieldValue.arrayRemove([userId]),
        });
        setState(() {
          _closeFriends.remove(userId);
        });
      }
    } catch (e) {
      print('Error toggling close friend: $e');
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _getFollowingDetails(
      String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${username} Close Friends')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _firestore.collection('users').doc(username).snapshots(),
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
                    return StreamBuilder<
                        DocumentSnapshot<Map<String, dynamic>>>(
                      stream: _getFollowingDetails(followingId),
                      builder: (context, detailsSnapshot) {
                        if (detailsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const ListTile(
                            title: Text('Loading...'),
                          );
                        }
                        if (detailsSnapshot.hasError) {
                          return ListTile(
                            title: Text('Error loading following details'),
                          );
                        }
                        if (!detailsSnapshot.hasData ||
                            !detailsSnapshot.data!.exists) {
                          return ListTile(
                            title: Text('Following details not found'),
                          );
                        }
                        var details = detailsSnapshot.data!.data()!;
                        var userId = details['uid'] ?? '';
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: FollowersCard(
                                  photourl: details['photourl'] ?? '',
                                  username: details['username'] ?? '',
                                  uid: userId,
                                ),
                              ),
                              Checkbox(
                                value: _closeFriends.contains(userId),
                                onChanged: (bool? value) {
                                  if (value != null) {
                                    _toggleCloseFriend(userId, value);
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

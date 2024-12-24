import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '/Controllers/Search_video.dart';
import '/Screens/Reel_Screen_Search.dart';
import '/Screens/Search_Screen_profile.dart';
import '/Screens/profile_screen.dart';
import '/utils/colors.dart';
import '/widgets/CircleTickIcon.dart';
import '/widgets/CircleTickIconSearch.dart';
import '/widgets/Video_player.dart';
import '/widgets/post_card.dart';
import '/model/user.dart' as u;
import '../widgets/videoplayersearch.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;
  late SearchVideoController videoController;
  var isMonetized;
  late List<DocumentSnapshot<Map<String, dynamic>>> filteredPosts;
  late List<DocumentSnapshot<Map<String, dynamic>>> filteredReels;

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchData() async {
    // Fetch data for 'Posts' where 'isGlobalOptionEnabled' is true
    QuerySnapshot<Map<String, dynamic>> postsSnapshot = await FirebaseFirestore
        .instance
        .collection('Posts')
        .where('isGlobalOptionEnabled', isEqualTo: true)
        .get();

    // Fetch data for 'reels' where 'isGlobalOptionEnabled' is true
    QuerySnapshot<Map<String, dynamic>> reelsSnapshot = await FirebaseFirestore
        .instance
        .collection('reels')
        .where('isGlobalOptionEnabled', isEqualTo: true)
        .get();

    // Now, you can work with the filtered postsSnapshot and reelsSnapshot where 'isGlobalOptionEnabled' is true
    filteredPosts = postsSnapshot.docs;
    filteredReels = reelsSnapshot.docs;

    // ... Rest of your code handling the fetched data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: searchController,
          decoration: InputDecoration(labelText: "Search for user"),
          onFieldSubmitted: (String s) {
            print(searchController.text);
            setState(() {
              isShowUsers = true;
            });
          },
        ),
      ),
      body: isShowUsers
          ? FutureBuilder(
              future: getUsers(searchController.text),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) {
                    isMonetized =
                        (snapshot.data! as dynamic).docs[index]['Monetization'];
                    print(isMonetized);
                    return InkWell(
                      onTap: () async {
                        final QuerySnapshot userSnapshot =
                            await FirebaseFirestore.instance
                                .collection("users")
                                .where("uid",
                                    isEqualTo: (snapshot.data! as dynamic)
                                        .docs[index]['uid'])
                                .get();
                        print((snapshot.data! as dynamic).docs[index]['uid']);
                        if (userSnapshot.docs.isNotEmpty) {
                          final userDoc = userSnapshot.docs.first;
                          final user = u.User.fromsnap(userDoc);
                          print({user.uid, user.username});
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                uid: (snapshot.data! as dynamic).docs[index]
                                    ['uid'],
                                user: user,
                              ),
                            ),
                          );
                        } else {
                          print("User not found ");
                        }
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              (snapshot.data! as dynamic).docs[index]
                                  ['photourl']),
                        ),
                        title: Row(
                          children: [
                            Text((snapshot.data! as dynamic).docs[index]
                                ['username']),
                            const SizedBox(),
                            isMonetized == "Monitized"
                                ? CircleTickIconSearch()
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : GestureDetector(
              onTap: () {},
              child: FutureBuilder(
                future: fetchData(),
                builder: (context, AsyncSnapshot<void> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: const CircularProgressIndicator(),
                    );
                  }
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                    ),
                    itemCount: filteredPosts.length + filteredReels.length,
                    itemBuilder: (context, index) {
                      if (index < filteredPosts.length) {
                        // Display Posts
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SearchScreenProfile(
                                  uid: filteredPosts[index]['uid'],
                                  username: filteredPosts[index]['username'],
                                ),
                              ),
                            );
                          },
                          child: Image.network(
                            filteredPosts[index]['posturl'],
                            fit: BoxFit.cover,
                          ),
                        );
                      } else {
                        // Display Reels Thumbnails
                        int reelsIndex = index - filteredPosts.length;
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SearchVideoScreen(
                                    uid: filteredReels[reelsIndex]['uid'],
                                    videoid: filteredReels[reelsIndex]['id']),
                              ),
                            );
                            print(filteredReels[reelsIndex]['uid']);
                            print(filteredReels[reelsIndex]['id']);
                          },
                          child: VideplayerSearch(
                            videourl: filteredReels[reelsIndex]['videourl'],
                            id: filteredReels[reelsIndex]['id'],
                            thumnail: filteredReels[reelsIndex]['thumbnail'],
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
    );
  }

  Future<QuerySnapshot<Object?>?> getUsers(String searchTerm) async {
    try {
      return await FirebaseFirestore.instance
          .collection("users")
          .where('username', isGreaterThanOrEqualTo: searchTerm)
          .where('username', isLessThan: searchTerm + '\uf8ff')
          .get();
    } catch (error) {
      print("Error fetching users: $error");
      return null; // Handle the error gracefully
    }
  }
}

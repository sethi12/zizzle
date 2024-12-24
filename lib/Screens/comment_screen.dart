import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/Screens/Splash_screen.dart';
import '/resources/firestoremethods.dart';
import '/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/comment_card.dart';

class CommentsScreen extends StatefulWidget {
  final snap;
  const CommentsScreen({super.key, required this.snap});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentcontrolller = TextEditingController();
  var username;
  var profilephoto;
  var uid;
  bool _isloading = false;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _commentcontrolller.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getuserdata();
  }

  Future<void> getuserdata() async {
    setState(() {
      _isloading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    var existinguser = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();
    profilephoto = existinguser.data()?['photourl'];
    uid = existinguser.data()?['uid'];
    setState(() {
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isloading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: const Text("Comments"),
              centerTitle: false,
            ),
            body: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Posts')
                  .doc(widget.snap['postid'])
                  .collection('Comments')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) => CommentCard(
                          snap: snapshot.data!.docs[index].data(),
                        ));
              },
            ),
            bottomNavigationBar: SafeArea(
              child: Container(
                height: kToolbarHeight,
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(profilephoto),
                      radius: 18,
                    ),
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.only(left: 16, right: 8),
                      child: TextField(
                        controller: _commentcontrolller,
                        decoration: InputDecoration(
                            hintText: "Comment", border: InputBorder.none),
                      ),
                    )),
                    InkWell(
                      onTap: () async {
                        await Firestoremethods().postcomment(
                            widget.snap['postid'],
                            _commentcontrolller.text,
                            uid,
                            username,
                            profilephoto);
                        setState(() {
                          _commentcontrolller.text = "";
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        child: const Text(
                          "Post",
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}

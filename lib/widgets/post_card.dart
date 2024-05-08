import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newapp/Screens/Global_benefits_screen.dart';
import 'package:newapp/Screens/comment_screen.dart';
import 'package:newapp/Screens/profile_screen.dart';
import 'package:newapp/model/user.dart';
import 'package:newapp/resources/firestoremethods.dart';
import 'package:newapp/utils/colors.dart';
import 'package:newapp/utils/utils.dart';
import 'package:newapp/widgets/CircleTickIcon.dart';
import 'package:newapp/widgets/like_animation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ads/ads_manager.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({super.key, required this.snap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool islikeanimating = false;
  String? username;
  var storeduid;
  int commentlength = 0;
  var Monetization;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getcomments();
    Admanager().loadrewardedad();
  }

  void getcomments() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.snap['postid'])
          .collection('Comments')
          .get();
     commentlength = querySnapshot.docs.length;
      final prefs = await SharedPreferences.getInstance();
      username = prefs.getString('username');
     print(username);
      var existingUser =  await FirebaseFirestore.instance.collection("users").doc(username).get();
      storeduid = existingUser.data()?['uid'];
      print(storeduid);
    }
    catch(e){
      showSnackBar(e.toString(), context);
    }
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: mobileBackgroundColor,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                .copyWith(right: 0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    widget.snap['profimage'],
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child:  widget.snap['collabreqacc']==false?GestureDetector(
                              onTap: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ProfileScreen(username: widget.snap['username'],uid: widget.snap["uid"],)));
                              },
                              child: Row(
                                children: [
                                  Text(
                                    "${widget.snap['username']}",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),

                                ],
                              ),
                            ):Row(
                              children: [
                                GestureDetector(onTap: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ProfileScreen(username: widget.snap['username'],uid: widget.snap["uid"],)));
                                },
                                    child: Text(widget.snap['username'])),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4,right: 4),
                                  child: Text("and"),
                                ),
                                GestureDetector(onTap: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ProfileScreen(username: widget.snap['collabusername'])));
                                },
                                    child: Text(widget.snap['collabusername'])),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              widget.snap['Location'],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )),
               storeduid == widget.snap['uid']? IconButton(
                    onPressed: () {
                      if (storeduid == widget.snap['uid']){
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 17),
                            shrinkWrap: true,
                            children: [
                                InkWell(
                                  child: Text("Delete Post"),
                                  onTap: () async {
                                    Firestoremethods().deletepost(widget.snap['postid']);
                                    Navigator.of(context).pop();
                                  },
                                ),const Divider(),
                              InkWell(
                                // Your second InkWell here
                                child: Text("Make it Global"),
                                onTap: () {
                                  if(widget.snap['Audience']=='Public') {
                                    if(widget.snap["isGlobalOptionEnabled"]==false){
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) =>
                                            GlobalBenefitsScreen(
                                              docid: widget.snap['postid'],)));
                                    }else{
                                      showSnackBar("Post Already Global", context);
                                    }
                                  }else{
                                    showSnackBar("Private post cant be Global", context);
                                  }
                                },
                              ),
                            ].toList(),
                          ),
                        ),
                      );}else{
                        // yet to doo............
                      }
                    },
                    icon: Icon(Icons.more_vert)):SizedBox(),
              ],
            ),
            //Image Section
          ),
          GestureDetector(
            onDoubleTap: () async {
              final prefs = await SharedPreferences.getInstance();
              username = prefs.getString('username');
              await Firestoremethods().LikePost(
                  widget.snap['postid'], username!, widget.snap['likes']);
              setState(() {
                islikeanimating = true;
              });
            },
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                width: double.infinity,
                child: Image.network(
                  widget.snap['posturl'],
                  fit: BoxFit.cover,
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: islikeanimating ? 1 : 0,
                child: LikeAnimation(
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 100,
                  ),
                  isAnimating: islikeanimating,
                  duration: const Duration(milliseconds: 400),
                  onEnd: () {
                    setState(() {
                      islikeanimating = false;
                    });
                  },
                ),
              ),
            ]),
          ),
          //LIke comment share
          Row(
            children: [
              LikeAnimation(
                isAnimating: widget.snap['likes'].contains(username),
                smallLike: true,
                child: IconButton(
                    onPressed: () async {
                      // final prefs = await SharedPreferences.getInstance();
                      // username = prefs.getString('username');
                      await Firestoremethods().LikePost(widget.snap['postid'],
                          username!, widget.snap['likes']);
                    },
                    icon: widget.snap['likes'].contains(username)
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 29,
                          )
                        : const Icon(
                            Icons.favorite_border,
                            size: 29,
                          )),
              ),
              IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                            snap: widget.snap,
                          ))),
                  icon: const Icon(
                    Icons.comment_outlined,
                    size: 29,
                  )),
              // IconButton(
              //     onPressed: () {},
              //     icon: const Icon(
              //       Icons.send,
              //       size: 29,
              //     )),
            //   Expanded(
            //       child: Align(
            //     alignment: Alignment.bottomRight,
            //     child: IconButton(
            //       icon: const Icon(Icons.bookmark_border),
            //       onPressed: () {},
            //     ),
            //   ))
            // ],
         ] ),

          //Description And Number of comments
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontWeight: FontWeight.w800),
                    child: Text(
                      '${widget.snap['likes'].length} likes',
                      style: Theme.of(context).textTheme.bodyText2,
                    )),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                        style: const TextStyle(color: primaryColor),
                        children: [
                          TextSpan(
                            text: widget.snap['username'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: "  ${widget.snap['caption']}",
                          ),
                        ]),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: GestureDetector(
                      onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CommentsScreen(snap: widget.snap))),
                      child: Text("View all $commentlength comments",
                        style:
                            const TextStyle(fontSize: 16, color: secondaryColor),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    DateFormat.yMMMd()
                        .format(widget.snap['datepublished'].toDate()),
                    style: const TextStyle(fontSize: 16, color: secondaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

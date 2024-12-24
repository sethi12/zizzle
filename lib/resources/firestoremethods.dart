import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '/model/post.dart';
import '/resources/post_storage_methods.dart';
import 'package:uuid/uuid.dart';

import 'Storage_methods.dart';

class Firestoremethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //upload post
  Future<String> uploadPost(
      String caption,
      Uint8List file,
      String uid,
      String Location,
      String Audience,
      String username,
      String profimage,
      String collabuser,
      String? trackid,
      String? previewurl,
      String? songname) async {
    String res = "Some Error Occured";
    try {
      String Photourl =
          await PostStorageMethods().UploadImagetoStorage('Posts', file, true);
      String postid = Uuid().v1();
      print(Photourl);
      print(postid);
      Post post = Post(
          Audience: Audience,
          uid: uid,
          username: username,
          caption: caption,
          Location: Location,
          datepublished: DateTime.now(),
          likes: [],
          postid: postid,
          posturl: Photourl,
          profimage: profimage,
          isGlobalOptionEnabled: false,
          collabusername: collabuser,
          collabreqacc: false,
          trackid: trackid,
          preivewUrl: previewurl,
          songname: songname);

      _firestore.collection('Posts').doc(postid).set(
            post.toJson(),
          );
      if (collabuser != "") {
        _firestore.collection("CollabRequests").doc(postid).set({
          "postid": postid,
          "posturl": Photourl,
          "profimage": profimage,
          "collabusername": collabuser,
          "username": username
        });
      }
      res = "Success";
      print(res);
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  LikePost(String postid, String username, List likes) async {
    try {
      if (likes.contains(username)) {
        await _firestore.collection('Posts').doc(postid).update({
          'likes': FieldValue.arrayRemove([username]),
        });
      } else {
        await _firestore.collection('Posts').doc(postid).update({
          'likes': FieldValue.arrayUnion([username]),
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }

  LikeVideo(String id, String username) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('reels').doc(id).get();
    if ((snapshot.data()! as dynamic)['likes'].contains(username)) {
      await _firestore.collection('reels').doc(id).update({
        'likes': FieldValue.arrayRemove([username]),
      });
    } else {
      await _firestore.collection('reels').doc(id).update({
        'likes': FieldValue.arrayUnion([username]),
      });
    }
  }

  Future<void> postcomment(String postid, String text, String uid,
      String username, String profilepic) async {
    try {
      if (text.isNotEmpty) {
        String Commentid = const Uuid().v1();
        await _firestore
            .collection('Posts')
            .doc(postid)
            .collection("Comments")
            .doc(Commentid)
            .set({
          'profilepic': profilepic,
          'username': username,
          'uid': uid,
          'text': text,
          'commentid': Commentid,
          'datepublished': DateTime.now(),
          'likes': []
        });
      } else {
        print("text is empty");
      }
    } catch (err) {
      print(err.toString());
    }
  }

  //deleting post
  Future<void> deletepost(String postid) async {
    try {
      await _firestore.collection("Posts").doc(postid).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> followuser(String myusername, String username) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(myusername).get();
      List following = (snapshot.data()! as dynamic)['following'];
      if (following.contains(username)) {
        await _firestore.collection('users').doc(username).update({
          'followers': FieldValue.arrayRemove([myusername])
        });

        await _firestore.collection('users').doc(myusername).update({
          'following': FieldValue.arrayRemove([username])
        });
      } else {
        await _firestore.collection('users').doc(username).update({
          'followers': FieldValue.arrayUnion([myusername])
        });
        await _firestore.collection('users').doc(myusername).update({
          'following': FieldValue.arrayUnion([username])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deletereel(String id) async {
    try {
      await _firestore.collection("reels").doc(id).delete();
    } catch (e) {
      print(e.toString());
    }
  }
}

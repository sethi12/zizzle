import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String uid;
  final String? username;
  final String Audience;
  final String Location;
  final String caption;
  final String postid;
  final datepublished;
  final String posturl;
  final String profimage;
  final likes;
  final bool isGlobalOptionEnabled;
  final String collabusername;
  final bool collabreqacc;
  final String? preivewUrl;
  final String? trackid;
  final String? songname;
  const Post(
      {required this.Audience,
      required this.uid,
      required this.username,
      required this.caption,
      required this.Location,
      required this.datepublished,
      required this.likes,
      required this.postid,
      required this.posturl,
      required this.profimage,
      required this.isGlobalOptionEnabled,
      required this.collabusername,
      required this.collabreqacc,
      this.preivewUrl,
      this.trackid,
      required this.songname});

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'username': username,
        'Audience': Audience,
        'caption': caption,
        'Location': Location,
        'datepublished': datepublished,
        'likes': likes,
        'postid': postid,
        'posturl': posturl,
        'profimage': profimage,
        'isGlobalOptionEnabled': isGlobalOptionEnabled,
        "collabusername": collabusername,
        "collabreqacc": collabreqacc,
        "trackid": trackid,
        "previewUrl": preivewUrl,
        "songname": songname
      };

  static Post fromsnap(DocumentSnapshot snapshot) {
    var snaoshot = snapshot.data() as Map<String, dynamic>;
    return Post(
        Audience: snaoshot['Audience'],
        uid: snaoshot['uid'],
        username: snaoshot['username'],
        caption: snaoshot['caption'],
        Location: snaoshot['Location'],
        datepublished: snaoshot['datepublished'],
        likes: snaoshot['likes'],
        postid: snaoshot['postid'],
        posturl: snaoshot['posturl'],
        profimage: snaoshot['profimage'],
        isGlobalOptionEnabled: snaoshot['isGlobalOptionEnabled'],
        collabusername: snaoshot["collabusername"],
        collabreqacc: snaoshot["collabreqacc"],
        trackid: snaoshot['trackid'],
        preivewUrl: snaoshot['previewUrl'],
        songname: snaoshot['songname']);
  }
}

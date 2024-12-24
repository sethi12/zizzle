import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

class Video {
  String username;
  String uid;
  String id;
  List likes;
  int commentcount;
  int sharecount;
  String Audience;
  String caption;
  String Location;
  String videourl;
  String profilephoto;
  String thumbnail;
  int views;
  String Paid;
  String Monetized;
  bool isGlobalOptionEnabled;
  bool collabreqacc;
  String collabusername;
  String? trackId;
  String? previewUrl;
  String? songname;
  String? track;
  Video({
    required this.username,
    required this.uid,
    required this.id,
    required this.likes,
    required this.commentcount,
    required this.sharecount,
    required this.Audience,
    required this.caption,
    required this.Location,
    required this.videourl,
    required this.profilephoto,
    required this.thumbnail,
    required this.views,
    required this.Paid,
    required this.Monetized,
    required this.isGlobalOptionEnabled,
    required this.collabreqacc,
    required this.collabusername,
    this.previewUrl,
    this.songname,
    this.trackId,
    this.track,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "id": id,
        "likes": likes,
        "commentcount": commentcount,
        "sharecount": sharecount,
        "Audience": Audience,
        "caption": caption,
        "Location": Location,
        "videourl": videourl,
        "profilephoto": profilephoto,
        "thumbnail": thumbnail,
        "views": views,
        "Paid": Paid,
        "Monetized": Monetized,
        "isGlobalOptionEnabled": isGlobalOptionEnabled,
        "collabreqacc": collabreqacc,
        "collabusername": collabusername,
        "previewUrl": previewUrl,
        "songname": songname,
        "trackId": trackId,
        "track": track,
      };
  static Video fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Video(
        username: snapshot['username'],
        uid: snapshot['uid'],
        id: snapshot['id'],
        likes: snapshot['likes'],
        commentcount: snapshot['commentcount'],
        sharecount: snapshot['sharecount'],
        Audience: snapshot['Audience'],
        caption: snapshot['caption'],
        Location: snapshot['Location'],
        videourl: snapshot['videourl'],
        profilephoto: snapshot['profilephoto'],
        thumbnail: snapshot['thumbnail'],
        views: snapshot['views'],
        Paid: snapshot['Paid'],
        Monetized: snapshot['Monetized'],
        isGlobalOptionEnabled: snapshot['isGlobalOptionEnabled'],
        collabreqacc: snapshot['collabreqacc'],
        collabusername: snapshot['collabusername'],
        previewUrl: snapshot['previewUrl'],
        songname: snapshot['songname'],
        track: snapshot['track'],
        trackId: snapshot['trackId']);
  }

  late VideoPlayerController _controller;

  Future<void> initializeController() async {
    _controller = VideoPlayerController.network(videourl);
    await _controller.initialize();
  }

  VideoPlayerController get controller => _controller;
}

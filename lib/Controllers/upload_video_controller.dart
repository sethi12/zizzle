import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '/model/reel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

class UploadVideoController extends GetxController {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  // _compressvideo(String videopath) async {
  //   final compressedvideo = await VideoCompress.compressVideo(videopath,
  //       quality: VideoQuality.Res640x480Quality);
  //   return compressedvideo!.file;
  // }
  Future<File?> _compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.Res640x480Quality,
      deleteOrigin:
          false, // Set to true to delete the original video after compression
    );
    if (compressedVideo == null) {
      print("Video compression failed.");
      return null;
    }

    // Check the file extension and format to ensure compatibility
    if (!compressedVideo.file!.path.endsWith('.mp4')) {
      print("Warning: Compressed video is not in MP4 format.");
    }

    return compressedVideo.file;
  }

  Future<String> _uploadVideoToStorage(String id, String videoPath) async {
    // File videoFile = File(videoPath);  // Create a File object from the video path
    // Reference ref = _storage.ref().child('reels').child(id);

    // UploadTask uploadTask = ref.putFile(await _compressVideo(videoPath));
    File? videoFile = await _compressVideo(videoPath);
    if (videoFile == null) return "Error: Compression failed.";

    Reference ref = _storage.ref().child('reels').child(id);
    UploadTask uploadTask = ref.putFile(videoFile);
    TaskSnapshot snap = await uploadTask;

    // Enable resumable uploads
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  _getThumbnail(String videopath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videopath);
    return thumbnail;
  }

  Future<String> _uploadImageToStorage(String id, String videopath) async {
    // File thumbnailFile = await _getThumbnail(videopath);
    Reference ref = _storage.ref().child('thumbnails').child(id);

    UploadTask uploadTask = ref.putFile(await _getThumbnail(videopath));
    TaskSnapshot snap = await uploadTask;

    // Enable resumable uploads
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

//upload video
  Future<String> uploadvideo(
      String caption,
      String Audience,
      String Location,
      String videopath,
      String collabuser,
      String songname,
      String previewUrl,
      String track,
      String trackId) async {
    String res = "Some Error Occurred";

    try {
      final prefs = await SharedPreferences.getInstance();
      String? username = prefs.getString('username');

      if (username != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(username).get();
        String reelid = Uuid().v1();
        String videourl = await _uploadVideoToStorage(reelid, videopath);
        String thumbnail = await _uploadImageToStorage(reelid, videopath);
        if ((userDoc.data() as Map<String, dynamic>)['Monetization'] ==
            "Monitized") {
          Video video = Video(
              username: username,
              uid: (userDoc.data() as Map<String, dynamic>)['uid'],
              // Provide a default value or handle null accordingly
              id: reelid,
              likes: [],
              commentcount: 0,
              sharecount: 0,
              Audience: Audience,
              caption: caption,
              Location: Location,
              videourl: videourl,
              profilephoto:
                  (userDoc.data() as Map<String, dynamic>)['photourl'],
              thumbnail: thumbnail,
              views: 0,
              Paid: 'Not Paid',
              Monetized: 'Monitized',
              isGlobalOptionEnabled: false,
              collabreqacc: false,
              collabusername: collabuser,
              songname: songname,
              previewUrl: previewUrl,
              track: track,
              trackId: trackId);
          if (collabuser != "") {
            await _firestore.collection("CollabRequests").doc(reelid).set({
              "reelid": reelid,
              "thumbnail": thumbnail,
              "profimage": (userDoc.data() as Map<String, dynamic>)['photourl'],
              "videourl": videourl,
              "videopath": videopath,
              "collabusername": collabuser,
              "username": username,
              "uid": (userDoc.data() as Map<String, dynamic>)['uid']
            });
          }
          await _firestore.collection('reels').doc(reelid).set(video.toJson());
          res = "Success";
        } else {
          Video video = Video(
              username: username,
              uid: (userDoc.data() as Map<String, dynamic>)['uid'],
              // Provide a default value or handle null accordingly
              id: reelid,
              likes: [],
              commentcount: 0,
              sharecount: 0,
              Audience: Audience,
              caption: caption,
              Location: Location,
              videourl: videourl,
              profilephoto:
                  (userDoc.data() as Map<String, dynamic>)['photourl'],
              thumbnail: thumbnail,
              views: 0,
              Paid: 'Paid',
              Monetized: 'Not Monitized',
              isGlobalOptionEnabled: false,
              collabusername: collabuser,
              collabreqacc: false,
              songname: songname,
              previewUrl: previewUrl,
              track: track,
              trackId: trackId);
          if (collabuser != "") {
            await _firestore.collection("CollabRequests").doc(reelid).set({
              "reelid": reelid,
              "thumbnail": thumbnail,
              "profimage": (userDoc.data() as Map<String, dynamic>)['photourl'],
              "videourl": videourl,
              "videopath": videopath,
              "collabusername": collabuser,
              "username": username,
              "uid": (userDoc.data() as Map<String, dynamic>)['uid']
            });
          }
          await _firestore.collection('reels').doc(reelid).set(video.toJson());

          res = "Success";
        }
      } else {
        // Handle the case when username is null
        res = "Error: Username is null";
      }
    } catch (err) {
      print("Error uploading video: $err");
      // Handle errors accordingly
      res = "Error: $err";
    }

    return res;
  }
}

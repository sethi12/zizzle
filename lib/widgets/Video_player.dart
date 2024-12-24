import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import '/Controllers/video_controller.dart';

import '../model/reel.dart'; // Import VideoController if not already imported

class VideoPlayerItem extends StatefulWidget {
  final String videourl;
  final String id;
  final String? spotifyPreviewUrl; // Nullable, in case no song is selected
  final String thumbnail;
  // final int currentindex;
  //  List<Video> videolist; // Add videolist here
  VideoPlayerItem(
      {Key? key,
      required this.videourl,
      required this.id,
      required this.thumbnail,
      this.spotifyPreviewUrl})
      : super(key: key);
  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController videoPlayerController;
  AudioPlayer? _audioPlayer; // For Spotify preview
  bool isVideoInitialized = false;
  int views = 0;
  final _firestore = FirebaseFirestore.instance;
  Timer? _timer;
  Duration _durationPlayed = Duration.zero;
  bool isreelviewed = false;

  @override
  void initState() {
    super.initState();
    initializeController();
    if (widget.spotifyPreviewUrl != null) {
      _initializeSpotifyPlayer(widget.spotifyPreviewUrl!);
    }
    _timer?.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer?.dispose();
    videoPlayerController.dispose();
    _timer?.cancel(); // Cancel the timer when disposing
  }

  Future<void> _initializeSpotifyPlayer(String previewUrl) async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer?.setUrl(previewUrl);
    _audioPlayer?.play();
  }

  Future<void> initializeController() async {
    videoPlayerController = VideoPlayerController.network(widget.videourl);
    await videoPlayerController.initialize();
    setState(() {
      isVideoInitialized = true;
    });
    videoPlayerController.play();
    if (widget.spotifyPreviewUrl != null) {
      videoPlayerController.setVolume(0); // Mute video if Spotify is playing
    } else {
      videoPlayerController.setVolume(1); // Play video audio otherwise
    }
    videoPlayerController.setLooping(true);
    // VideoController().preloadVideos(); // Assuming preloadVideos is a method in your VideoController

    // Preload the next video

    // Listen for video player events
    videoPlayerController.addListener(() {
      if (videoPlayerController.value.isPlaying) {
        // Start the timer when the video starts playing
        _timer = Timer.periodic(Duration(seconds: 8), (Timer timer) {
          if (mounted) {
            setState(() {
              _durationPlayed += Duration(seconds: 8);
            });

            // Check if 30 seconds have passed
            if (_durationPlayed.inSeconds >= 8 && !isreelviewed) {
              // Update views after 30 seconds
              updateViews();
              setState(() {
                _durationPlayed = Duration.zero; // Reset duration
              });
            }
          } else {
            timer.cancel(); // Stop the timer if the widget is not mounted
          }
        });
      }
      // preloadNextVideo();
    });
  }

  // void preloadNextVideo() async {
  //   if (widget.currentindex < widget.videolist.length - 1) {
  //     await VideoPlayerController.network(widget.videolist[widget.currentindex + 1].videourl).initialize();
  //   }
  // }

  void updateViews() async {
    try {
      // Increment the view count in Firestore
      await _firestore.collection("reels").doc(widget.id).update({
        'views': FieldValue.increment(1),
      });

      // Update the local views count
      setState(() {
        views++;
        isreelviewed = true;
      });

      print('$views views');
    } catch (e) {
      print('Error updating views: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      // onTap: () {
      //   if (videoPlayerController.value.isPlaying) {
      //     videoPlayerController.pause();
      //   } else {
      //     videoPlayerController.play();
      //   }
      // },
      onTap: () {
        if (videoPlayerController.value.isPlaying) {
          videoPlayerController.pause();
          _audioPlayer?.pause();
        } else {
          videoPlayerController.play();
          _audioPlayer?.play();
        }
      },
      child: Container(
        decoration: const BoxDecoration(color: Colors.black),
        child: Center(
          child: Stack(
            children: [
              // Thumbnail
              Visibility(
                visible: !isVideoInitialized ||
                    !videoPlayerController.value.isPlaying,
                child: Image.network(
                  widget.thumbnail,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              if (!videoPlayerController
                  .value.isPlaying) // Show pause icon when paused
                Center(
                  child: Icon(
                    Icons.pause,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              // Video Player
              Visibility(
                visible:
                    isVideoInitialized && videoPlayerController.value.isPlaying,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double videoWidth = size.width;
                    double videoHeight =
                        size.width / videoPlayerController.value.aspectRatio;

                    if (videoWidth < constraints.maxWidth ||
                        videoHeight < constraints.maxHeight) {
                      // If the video size is smaller than the device size, use the original size
                      videoWidth = size.width;
                      videoHeight =
                          size.width / videoPlayerController.value.aspectRatio;
                    }

                    return SizedBox(
                      width: videoWidth,
                      height: videoHeight,
                      child: VideoPlayer(videoPlayerController),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/Screens/add_reel_details.dart';
import '/Screens/edit_video_screen.dart';

class AddreelScreen extends StatelessWidget {
  const AddreelScreen({super.key});
  pickvideo(ImageSource src, BuildContext context) async {
    final video = await ImagePicker().pickVideo(source: src);
    if (video != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddReelDetails(
              videofile: File(video.path), videopath: video.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () => pickvideo(ImageSource.gallery, context),
          child: Container(
            width: 190,
            height: 50,
            decoration: BoxDecoration(color: Colors.white30),
            child: const Center(
              child: Text(
                "Add Reel",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

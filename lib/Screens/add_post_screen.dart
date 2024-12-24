import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '/Screens/Add_post_screen_details.dart';
import '/Screens/Splash_screen.dart';
import '/utils/colors.dart';
import 'dart:io';
import '/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

class AddpostScreen extends StatefulWidget {
  const AddpostScreen({super.key});

  @override
  State<AddpostScreen> createState() => _AddpostScreenState();
  // static Uint8List? selectedimage = _AddpostScreenState.selectedImage;
  // static var uid = _AddpostScreenState.uid;
  // static var photourl =_AddpostScreenState.photourl;
}

class _AddpostScreenState extends State<AddpostScreen> {
  static Uint8List? selectedImage;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? usernmaee = SplashScreen.username;
  // static var uid;
  // static var photourl;

  Future<void> pickImage() async {
    Uint8List file = await PickImage(ImageSource.gallery);
    if (file != null) {
      await cropImage(file);
    }
  }

  Future<void> cropImage(Uint8List imgFile) async {
    File file = await _createFileFromBytes(imgFile);
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );

    if (croppedFile != null) {
      Uint8List croppedBytes = await croppedFile.readAsBytes();
      setState(() {
        selectedImage = croppedBytes;
      });
    }
  }

  Future<File> _createFileFromBytes(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final tempFileName = 'temp_image.jpg';

    File tempFile = File('$tempPath/$tempFileName');
    await tempFile.writeAsBytes(bytes);

    return tempFile;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        elevation: 0.9,
        title: const Text(
          "New Post",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                child: Text(
                  "Next",
                  style: TextStyle(fontSize: 15, color: Colors.blue),
                ),
                onTap: () {
                  // getdata();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddpostScreenDetails(
                            selectedimage: selectedImage,
                          )));
                },
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: screenWidth * 0.7, // Adjust the height as needed
                width: double.infinity,
                color: mobileBackgroundColor,
                child: selectedImage != null
                    ? Image.memory(
                        selectedImage!, // Convert String to File
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Text(
                          "No Image Selected",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              Container(
                width: double.infinity,
                height: 40,
                color: mobileBackgroundColor,
                child: Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Please select an image ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                itemCount: 3,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    child: YourGalleryItemWidget(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  // void getdata()async{
  //   try{
  //     var existingUser = await _firestore.collection("users").doc(usernmaee).get();
  //     print(existingUser);
  //     uid = existingUser.data()?['uid'];
  //     photourl = existingUser.data()?['photourl'];
  //     print(uid);
  //     print(usernmaee);
  //     print(photourl);
  //   }
  //   catch(err){
  //     print(err.toString());
  //   }
  // }
}

class YourGalleryItemWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace this with your custom gallery item widget
    return Container(
      color: mobileBackgroundColor,
      child: Center(
        child: Icon(Icons.image),
      ),
    );
  }
}

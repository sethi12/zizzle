import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '/Screens/Add_post_screen_details.dart';
import '/Screens/Splash_screen.dart';
import '/Screens/profile_screen.dart';
import '/resources/Storage_methods.dart';
import '/utils/colors.dart';
import 'dart:io';
import '/utils/utils.dart';
import '/widgets/text_feild_input.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firestore = FirebaseFirestore.instance;
  var userdata = {};
  var storeduid;
  var myusername;
  var photo;
  Uint8List? _image;
  var _isLoading;
  bool _ischanged = false;
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController Catecontroller = TextEditingController();
  final TextEditingController BioController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
                backgroundColor: mobileBackgroundColor,
                title: Text("Edit Profile"),
                centerTitle: false,
                actions: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GestureDetector(
                        child: Text(
                          "Save",
                          style: TextStyle(fontSize: 15, color: Colors.blue),
                        ),
                        onTap: () => Updatetask(),
                      ),
                    ),
                  )
                ]),
            body: Column(
              children: [
                SizedBox(
                  height: 25,
                  width: 150,
                ),
                InkWell(
                    onTap: () {
                      SelectImage();
                    },
                    child: _image != null
                        ? CircleAvatar(
                            backgroundImage: MemoryImage(_image!),
                            radius: 54,
                          )
                        : CircleAvatar(
                            backgroundImage: NetworkImage(photo),
                            radius: 54,
                          )),
                SizedBox(
                  height: 15,
                ),
                InkWell(
                    onTap: () => SelectImage(),
                    child: Text(
                      "Edit ProfileImage",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    )),
                SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          "Name",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Category",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Bio",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20, left: 15),
                          child: SizedBox(
                            height: 30,
                            width: MediaQuery.of(context).size.width * 0.73,
                            child: TextFeildInput(
                                textInputType: TextInputType.text,
                                textEditingController: namecontroller,
                                hinttext: "Enter Your Name"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20, left: 15),
                          child: SizedBox(
                            height: 30,
                            width: MediaQuery.of(context).size.width * 0.73,
                            child: TextFeildInput(
                                textInputType: TextInputType.text,
                                textEditingController: Catecontroller,
                                hinttext:
                                    "Category like influencer,creator etc.."),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: SizedBox(
                            height: 30,
                            width: MediaQuery.of(context).size.width * 0.73,
                            child: TextFeildInput(
                                textInputType: TextInputType.text,
                                textEditingController: BioController,
                                hinttext: "Enter Your Bio"),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          );
  }

  getdata() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    myusername = prefs.getString('username');
    print(myusername);
    try {
      var existingUser =
          await _firestore.collection("users").doc(myusername).get();
      print(existingUser);
      if (existingUser.exists) {
        storeduid = existingUser.data()?['uid'];
        print("Storeduid==================${storeduid}");
        photo = existingUser.data()?['photourl'];
        print('photo=======${photo}');
      }

      setState(() {});
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  void SelectImage() async {
    Uint8List profileimage = await PickImage(ImageSource.gallery);
    setState(() {
      _image = profileimage;
    });
  }

  void Updatetask() async {
    if (_image != null) {
      setState(() {
        _isLoading = true;
      });
      String photourl = await StorageMethods()
          .UploadImagetoStorage("ProfilePics", _image!, false, storeduid);
      await _firestore.collection('users').doc(myusername).update({
        'photourl': photourl,
      });
      QuerySnapshot querySnapshot = await _firestore
          .collection('Posts')
          .where('uid', isEqualTo: storeduid)
          .get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        // Get the document ID
        String documentId = documentSnapshot.id;

        // Update the specific document using the document ID
        await _firestore.collection('Posts').doc(documentId).update({
          'profimage': photourl,
          // add other fields you want to update here
        });
      }
      QuerySnapshot querySnapshott = await _firestore
          .collection('reels')
          .where('uid', isEqualTo: storeduid)
          .get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshott.docs) {
        // Get the document ID
        String documentId = documentSnapshot.id;

        // Update the specific document using the document ID
        await _firestore.collection('reels').doc(documentId).update({
          'profilephoto': photourl,
          // add other fields you want to update here
        });
      }
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
      // part of ifff ======================
    } else {
      setState(() {
        _isLoading = true;
      });
      if (namecontroller.text.isNotEmpty &&
          BioController.text.isEmpty &&
          Catecontroller.text.isEmpty) {
        await _firestore.collection('users').doc(myusername).update({
          'name': namecontroller.text,
        });
      } else if (namecontroller.text.isEmpty &&
          BioController.text.isNotEmpty &&
          Catecontroller.text.isEmpty) {
        await _firestore.collection('users').doc(myusername).update({
          'Bio': BioController.text,
        });
      } else if (namecontroller.text.isEmpty &&
          BioController.text.isEmpty &&
          Catecontroller.text.isNotEmpty) {
        await _firestore.collection('users').doc(myusername).update({
          'Category': Catecontroller.text,
        });
      } else if (namecontroller.text.isNotEmpty &&
          BioController.text.isNotEmpty &&
          Catecontroller.text.isNotEmpty) {
        await _firestore.collection('users').doc(myusername).update({
          'name': namecontroller.text,
          'Bio': BioController.text,
          'Category': Catecontroller.text,
        });
      }
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    }
  }
}

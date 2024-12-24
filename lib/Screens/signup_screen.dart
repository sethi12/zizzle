import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import '/Screens/login_screen.dart';
import '/utils/utils.dart';
import '../utils/colors.dart';
import '../widgets/text_feild_input.dart';
import 'Screen_Signup.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
  static String username = _SignupScreenState._usernamecontroller.text;
  static Uint8List? profilepic = _SignupScreenState._image;
}

class _SignupScreenState extends State<SignupScreen> {
  static final TextEditingController _usernamecontroller =
      TextEditingController();
  static Uint8List? _image;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _usernamecontroller.dispose();
  }

  void SelectImage() async {
    Uint8List profileimage = await PickImage(ImageSource.gallery);
    setState(() {
      _image = profileimage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //svg image
              Flexible(
                child: Container(),
                flex: 1,
              ),
              Image.asset(
                "assets/applogo.jpeg",
                height: 64,
              ),
              const SizedBox(height: 44),
              //Circular Widget to show our selected file
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_image!) //Memory image
                          )
                      : const CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(
                              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSqKCA0WCWoqjIX5hwq6JFfaakFaA2qzhHOUGdFx7vARMfel6LqTGZPT0Du&s=10"),
                        ),
                  Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: SelectImage,
                        icon: const Icon(Icons.add_a_photo),
                      ))
                ],
              ),
              const SizedBox(height: 24),
              //Text feild input for email/username
              TextFeildInput(
                  textInputType: TextInputType.text,
                  textEditingController: _usernamecontroller,
                  hinttext: "Enter your Username"),
              const SizedBox(height: 24),

              // button for login
              InkWell(
                  child: Container(
                    child: const Text("Next"),
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4))),
                        color: blueColor),
                  ),
                  onTap: () {
                    if (_usernamecontroller.text.isEmpty) {
                      showSnackBar('please create a username', context);
                    } else if (_image == null) {
                      showSnackBar('please upload a profile pic', context);
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupScreen2()));
                    }
                  }),
              Flexible(
                child: Container(),
                flex: 2,
              ),

              const SizedBox(
                height: 12,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: const Text(
                      " have an account?",
                      style: TextStyle(fontSize: 17),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => LoginScreen()));
                    },
                    child: Container(
                      child: const Text(
                        "Login",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ],
              )
              //transitioning to signup
            ],
          ),
        ),
      ),
    );
  }
}

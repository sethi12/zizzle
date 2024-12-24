import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '/Screens/login_screen.dart';
import '/Screens/signup_screen.dart';
import '/Screens/signup_screen.dart';
import '/utils/utils.dart';
import '../resources/auth_methods.dart';
import '../utils/colors.dart';
import '../widgets/text_feild_input.dart';

class SignupScreen2 extends StatefulWidget {
  const SignupScreen2({super.key});

  @override
  State<SignupScreen2> createState() => _SignupScreenState2();
}

class _SignupScreenState2 extends State<SignupScreen2> {
  final TextEditingController _passwordcontroller = TextEditingController();
  final TextEditingController _emailcontroller = TextEditingController();
  String username = SignupScreen.username;
  Uint8List? _profileimage = SignupScreen.profilepic;
  bool _isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _passwordcontroller.dispose();
    _emailcontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
      ),
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
                flex: 2,
              ),
              //Text feild input for email/username
              SvgPicture.asset(
                "assets/instagram-one-svgrepo-com.svg",
                color: primaryColor,
                height: 64,
              ),
              const SizedBox(height: 64),
              TextFeildInput(
                  textInputType: TextInputType.emailAddress,
                  textEditingController: _emailcontroller,
                  hinttext: "Enter your Email"),
              const SizedBox(height: 24),
              //Text feild input for passwrod
              TextFeildInput(
                  textInputType: TextInputType.text,
                  textEditingController: _passwordcontroller,
                  ispass: true,
                  hinttext: "Enter your password"),
              const SizedBox(height: 24),
              // button for login
              InkWell(
                  child: Container(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : const Text("Sign Up"),
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4))),
                        color: blueColor),
                  ),
                  onTap: SignUpUser),
              const SizedBox(
                height: 12,
              ),
              Flexible(
                child: Container(),
                flex: 2,
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

  void SignUpUser() async {
    if (_passwordcontroller.text.isEmpty || _emailcontroller.text.isEmpty) {
      // yet to done
    } else {
      setState(() {
        _isLoading = true;
      });
      String res = await Authmethods().siginUser(
          username: username.trim(),
          email: _emailcontroller.text.trim(),
          password: _passwordcontroller.text.trim(),
          file: _profileimage!);

      print(res);
      if (res == "User registered successfully!") {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
        showSnackBar(res + "please login", context);

        setState(() {
          _isLoading = false;
        });
      } else {
        showSnackBar(res, context);
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      }
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/Screens/profile_screen.dart';
import '/ads/ads_manager.dart';
import '/utils/colors.dart';
import '/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalBenefitsScreen extends StatefulWidget {
  var docid;
  GlobalBenefitsScreen({super.key, required this.docid});

  @override
  State<GlobalBenefitsScreen> createState() => _GlobalBenefitsScreenState();
}

class _GlobalBenefitsScreenState extends State<GlobalBenefitsScreen> {
  var username;
  var existinguser;
  bool done = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Admanager().loadrewardedad();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text("Benefits"),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                  children: [
                    TextSpan(
                        text:
                            'Unlocking the global benefits on Zizzle transforms your content strategy by propelling your posts and reels to the forefront of the platform. The global option ensures that your creations are not confined to your existing followers but are showcased prominently on the search and home screens of all users. This presents a golden opportunity for content creators to garner extra views and likes, significantly amplifying their impact within the vibrant Zizzle community.\n\n'),
                    TextSpan(
                        text:
                            'What sets this feature apart is its adaptability. The global option operates solely when the Zizzle app is open, automatically disabling when closed. This nuanced approach gives users the flexibility to choose when their content receives global exposure, maintaining a balance between broad visibility and personal privacy. It\'s a strategic tool that empowers creators to expand their audience organically while retaining control over the extent of their content\'s reach.',
                        style: TextStyle(color: Colors.red)),
                    TextSpan(
                        text:
                            '\n\nThis feature encourages a diverse range of users to discover and appreciate your creativity, cultivating a thriving community where content resonates on a global scale.'),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Admanager().showrewardedad(widget.docid);
            },
            child: Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.blueAccent,
              width: double.infinity, // Set your desired color
              child: Center(
                child: Text(
                  'Make it Global',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

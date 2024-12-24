import 'package:flutter/material.dart';
import '/Screens/add_post_screen.dart';
import '/Screens/add_reel_screen.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

int _currentindex = 0;

class _AddScreenState extends State<AddScreen> {
  late PageController pageController;
  @override
  void initState() {
    // TODO: implement initState
    pageController = PageController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }

  onpagechanged(int page) {
    setState(() {
      _currentindex = page;
    });
  }

  navigationtapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView(
              controller: pageController,
              onPageChanged: onpagechanged,
              children: const [AddpostScreen(), AddreelScreen()],
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              bottom: 10,
              right: _currentindex == 0 ? 100 : 150,
              child: Container(
                width: 140,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        navigationtapped(0);
                      },
                      child: Text(
                        "Post",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color:
                              _currentindex == 0 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        navigationtapped(1);
                      },
                      child: Text(
                        "Reels",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color:
                              _currentindex == 1 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

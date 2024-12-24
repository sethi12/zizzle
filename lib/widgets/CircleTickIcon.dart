import 'package:flutter/material.dart';
class CircleTickIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: const CircleAvatar(
        radius: 10,
        backgroundColor: Colors.grey, // Set your preferred circle color
        child: Icon(
          Icons.check_circle,
          size: 18,
          color: Colors.black, // Set your preferred tick color
        ),
      ),
    );
  }
}
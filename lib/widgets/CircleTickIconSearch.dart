import 'package:flutter/material.dart';
class CircleTickIconSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: const CircleAvatar(
        radius: 8,
        backgroundColor: Colors.grey, // Set your preferred circle color
        child: Icon(
          Icons.check_circle,
          size: 14,
          color: Colors.black, // Set your preferred tick color
        ),
      ),
    );
  }
}